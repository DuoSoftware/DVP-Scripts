/*
* FreeSWITCH Modular Media Switching Software Library / Soft-Switch Application
* Copyright (C) 2005-2014, Anthony Minessale II <anthm@freeswitch.org>
*
* Version: MPL 1.1
*
* The contents of this file are subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use this file except in compliance with
* the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is FreeSWITCH Modular Media Switching Software Library / Soft-Switch Application
*
* The Initial Developer of the Original Code is
* Anthony Minessale II <anthm@freeswitch.org>
* Portions created by the Initial Developer are Copyright (C)
* the Initial Developer. All Rights Reserved.
*
* Contributor(s):
*
* Marc Olivier Chouinard <mochouinard@moctel.com>
* Emmanuel Schmidbauer <e.schmidbauer@gmail.com>
* Ítalo Rossi <italorossib@gmail.com>
*
* mod_ards.c -- Call Center Module
*
*/
#include <switch.h>
#include <switch_curl.h>

#define ARDS_EVENT "ards::info"
#define VM_MESSAGE_COUNT_MACRO "voicemail_message_count"

static struct {
	switch_hash_t *ards_hash;
	int debug;
	char *id;
	int32_t threads;
	int32_t running;
	char *url;
	char *registerurl;
	char *qurl;
	char *uurl;
	char *durl;
	char *nurl;
	char *rpc_url;
	char *security_token;
	char *recordPath;
	switch_mutex_t *mutex;
	switch_memory_pool_t *pool;
	char *rurl;
} globals;



/* Prototypes */
SWITCH_MODULE_SHUTDOWN_FUNCTION(mod_ards_shutdown);
SWITCH_MODULE_RUNTIME_FUNCTION(mod_ards_runtime);
SWITCH_MODULE_LOAD_FUNCTION(mod_ards_load);

/* SWITCH_MODULE_DEFINITION(name, load, shutdown, runtime)
* Defines a switch_loadable_module_function_table_t and a static const char[] modname
*/
SWITCH_MODULE_DEFINITION(mod_ards, mod_ards_load, mod_ards_shutdown, NULL);

static const char *global_cf = "ards.conf";


struct call_helper {
	const char *member_uuid;
	const char *member_session_uuid;
	const char *agent_uuid;
	const char *originate_string;
	const char *member_cid_number;
	const char *member_cid_name;
	const char *company;
	const char *tenant;
	const char *resource_id;
	const char *resource_name;
	const char *servertype;
	const char *requesttype;
	const char *skills;
	const char *originate_type;
	const char *originate_domain;
	const char *originate_user;
	const char *originate_display;
	const char *profile_name;
	const char *business_unit;


	switch_memory_pool_t *pool;
};

struct http_data_obj {
	switch_stream_handle_t stream;
	switch_size_t bytes;
	switch_size_t max_bytes;
	switch_memory_pool_t *pool;
	int err;
	long http_response_code;
	char *http_response;
	switch_curl_slist_t *headers;
};

typedef struct http_data_obj http_data_t;

typedef enum {
	ARDS_COMPLETED = 0,
	ARDS_REMOVE = 1,
	ARDS_EXPIRE = 2,
	ARDS_RING_REJECTED = 3,
	ARDS_REJECTED = 4
} ards_msg_type;

typedef enum {
	ARDS_PRE_MOH = 0,
	ARDS_MOH = 1,
	ARDS_MOH_ANNOUNCEMENT = 2,
	ARDS_POSITION_ANNOUNCEMENT = 3,
	ARDS_REPEAT_POSITION_ANNOUNCEMENT = 4
} ards_moh_step;

switch_time_t local_epoch_time_now(switch_time_t *t)
{
	switch_time_t now = switch_micro_time_now() / 1000000; /* APR_USEC_PER_SEC */
	if (t) {
		*t = now;
	}
	return now;
}

static switch_status_t ards_on_dtmf(switch_core_session_t *session, void *input, switch_input_type_t itype, void *buf, unsigned int buflen)
{
	switch (itype) {
	case SWITCH_INPUT_TYPE_DTMF:
	{
		switch_dtmf_t *dtmf = (switch_dtmf_t *)input;

		if (dtmf->digit == '#') {
			return SWITCH_STATUS_BREAK;
		}
	}
	default:
		break;
	}

	return SWITCH_STATUS_SUCCESS;
}

static switch_status_t load_config(void)
{
	switch_status_t status = SWITCH_STATUS_SUCCESS;
	switch_xml_t cfg, xml, settings, param;

	if (!(xml = switch_xml_open_cfg(global_cf, &cfg, NULL))) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Open of %s failed\n", global_cf);
		status = SWITCH_STATUS_TERM;
		goto end;
	}

	switch_mutex_lock(globals.mutex);
	if ((settings = switch_xml_child(cfg, "settings"))) {
		for (param = switch_xml_child(settings, "param"); param; param = param->next) {
			char *var = (char *)switch_xml_attr_soft(param, "name");
			char *val = (char *)switch_xml_attr_soft(param, "value");

			switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_INFO, "Key %s value %s\n", var, val);

			if (!strcasecmp(var, "debug")) {
				globals.debug = atoi(val);
			}
			else if (!strcasecmp(var, "url")) {
				globals.url = strdup(val);
			}
			else if (!strcasecmp(var, "record-format")) {
				globals.recordPath = strdup(val);
			}
			else if (!strcasecmp(var, "profile-url")) {
				globals.qurl = strdup(val);
			}
			else if (!strcasecmp(var, "upload-url")) {
				globals.uurl = strdup(val);
			}
			else if (!strcasecmp(var, "recording-url")) {
				globals.rurl = strdup(val);
			}

			else if (!strcasecmp(var, "download-url")) {
				globals.durl = strdup(val);
			}
			else if (!strcasecmp(var, "register-url")) {
				globals.registerurl = strdup(val);
			}
			else if (!strcasecmp(var, "xml_rpc")) {
				globals.rpc_url = strdup(val);
			}
			else if (!strcasecmp(var, "security_token")) {
				globals.security_token = strdup(val);
			}
			else if (!strcasecmp(var, "notification_url")) {
				globals.nurl = strdup(val);
			}
			else if (!strcasecmp(var, "serverid")) {
				globals.id = strdup(val);
			}


		}
	}


end:
	switch_mutex_unlock(globals.mutex);

	if (xml) {
		switch_xml_free(xml);
	}

	return status;
}

static size_t header_callback(void *ptr, size_t size, size_t nmemb, void *data)
{
	register unsigned int realsize = (unsigned int)(size * nmemb);
	http_data_t *http_data = data;
	char *header = NULL;

	header = switch_core_alloc(http_data->pool, realsize + 1);
	switch_copy_string(header, ptr, realsize);
	header[realsize] = '\0';

	http_data->headers = switch_curl_slist_append(http_data->headers, header);

	return realsize;
}

static size_t file_callback(void *ptr, size_t size, size_t nmemb, void *data)
{
	register unsigned int realsize = (unsigned int)(size * nmemb);
	http_data_t *http_data = data;

	http_data->bytes += realsize;

	if (http_data->bytes > http_data->max_bytes) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Oversized file detected [%d bytes]\n", (int)http_data->bytes);
		http_data->err = 1;
		return 0;
	}

	http_data->stream.write_function(&http_data->stream, "%.*s", realsize, ptr);
	return realsize;
}

static void Inform_ards(ards_msg_type type, const char *uuid, const char *reason, int company, int tenant) {

	const char *url = globals.url;
	switch_memory_pool_t *pool = NULL;
	switch_CURL *curl_handle = NULL;
	http_data_t *http_data = NULL;
	switch_curl_slist_t *headers = NULL;
	long httpRes = 0;

	char *tmpurl;
	char *ctx = switch_mprintf("authorization: Bearer %s", globals.security_token);
	char *cto = switch_mprintf("companyinfo: %d:%d", tenant, company);

	switch_core_new_memory_pool(&pool);
	curl_handle = switch_curl_easy_init();

	http_data = switch_core_alloc(pool, sizeof(http_data_t));
	memset(http_data, 0, sizeof(http_data_t));
	http_data->pool = pool;

	http_data->max_bytes = 64000;
	SWITCH_STANDARD_STREAM(http_data->stream);



	switch (type) {
	case ARDS_COMPLETED:
		tmpurl = switch_mprintf( "%s/%s/%s", url, uuid, "NONE");
		break;

	case ARDS_REMOVE:
		tmpurl = switch_mprintf("%s/%s/%s", url, uuid, "NONE");
		break;

	case ARDS_EXPIRE:
		tmpurl = switch_mprintf("%s/%s/reject/%s", url, uuid, "NoSession");
		break;

	case ARDS_REJECTED:
		tmpurl = switch_mprintf("%s/%s/reject/%s", url, uuid, "AgentRejected");
		break;

	case ARDS_RING_REJECTED:
		tmpurl = switch_mprintf("%s/%s/reject/%s", url, uuid, "ClientRejected");
		break;

	default:
		tmpurl = switch_mprintf("%s", url);
		break;
	}



	headers = switch_curl_slist_append(headers, ctx);
	switch_safe_free(ctx);

	headers = switch_curl_slist_append(headers, cto);
	switch_safe_free(cto);





	//struct data_stream dstream = { NULL };
	switch_curl_easy_setopt(curl_handle, CURLOPT_CUSTOMREQUEST, "DELETE");
	//switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPGET, 1);
	switch_curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1);
	switch_curl_easy_setopt(curl_handle, CURLOPT_MAXREDIRS, 15);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPAUTH, CURLAUTH_ANY);

	switch_curl_easy_setopt(curl_handle, CURLOPT_URL, tmpurl);
	switch_curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);
	switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, file_callback);
	switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)http_data);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERFUNCTION, header_callback);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERDATA, (void *)http_data);
	switch_curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "freeswitch-curl/1.0");
	switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, headers);

	switch_curl_easy_perform(curl_handle);
	switch_curl_easy_getinfo(curl_handle, CURLINFO_RESPONSE_CODE, &httpRes);
	switch_curl_easy_cleanup(curl_handle);
	switch_curl_slist_free_all(headers);

	if (http_data->stream.data && !zstr((char *)http_data->stream.data) && strcmp(" ", http_data->stream.data)) {

		http_data->http_response = switch_core_strdup(pool, http_data->stream.data);
	}

	http_data->http_response_code = httpRes;

	switch_safe_free(http_data->stream.data);
	switch_safe_free(tmpurl);

	if (http_data && http_data->headers) {
		switch_curl_slist_free_all(http_data->headers);
	}

	if (pool) {
		switch_core_destroy_memory_pool(&pool);
	}



}

static switch_status_t add_ards(int company, int tenant, const char* skill, const char *uuid, switch_channel_t *channel, const char *priority, const char* bussinessunit) {

	const char *url = globals.url;
	switch_memory_pool_t *pool = NULL;
	switch_CURL *curl_handle = NULL;
	http_data_t *http_data = NULL;
	switch_curl_slist_t *headers = NULL;
	//const char *data = NULL;
	//switch_curl_slist_t *headers = NULL;
	long httpRes = 0;
	switch_status_t status = SWITCH_STATUS_SUCCESS;
	cJSON *jdata;
	cJSON *a;

	//char tmpurl[1000];
	//char *msg;
	char *p = "{}";

	cJSON *cj, *cjp, *cjr;

	char *ct = switch_mprintf("Content-Type: %s", "application/json");
	char *ctx = switch_mprintf("authorization: Bearer %s", globals.security_token);
	char *cto = switch_mprintf("companyinfo: %d:%d", tenant, company);
	char *com = switch_mprintf("%d", company);
	char *ten = switch_mprintf("%d", tenant);
	const char *strings[20] = { 0 };

	switch_event_t *event;



	char *mycmd = NULL;
	char *argv[20] = { 0 };

	int argc = 0;

	if (!zstr(skill) && (mycmd = strdup(skill))) {
		argc = switch_split(mycmd, ',', argv);
	}


	for (int i = 0; i < argc; i++) {
		strings[i] = (const char*)argv[i];
	}


	switch_core_new_memory_pool(&pool);
	curl_handle = switch_curl_easy_init();

	http_data = switch_core_alloc(pool, sizeof(http_data_t));
	memset(http_data, 0, sizeof(http_data_t));
	http_data->pool = pool;

	http_data->max_bytes = 64000;
	SWITCH_STANDARD_STREAM(http_data->stream);
	//switch_snprintf(tmpurl, sizeof(tmpurl), "%s/add", url);

	//msg = switch_mprintf("%s|%d|%d|%s", uuid, company, tenant, skill);


	jdata = cJSON_CreateObject();
	cJSON_AddNumberToObject(jdata, "Company", company);
	cJSON_AddNumberToObject(jdata, "Tenant", tenant);
	cJSON_AddStringToObject(jdata, "ServerType", "CALLSERVER");
	cJSON_AddStringToObject(jdata, "CallbackOption", "GET");
	cJSON_AddStringToObject(jdata, "RequestType", "CALL");
	cJSON_AddStringToObject(jdata, "SessionId", uuid);
	cJSON_AddStringToObject(jdata, "RequestServerId", globals.id);
	cJSON_AddStringToObject(jdata, "Priority", priority);
	cJSON_AddStringToObject(jdata, "OtherInfo", "");
	cJSON_AddStringToObject(jdata, "BusinessUnit", bussinessunit);



	a = cJSON_CreateStringArray(strings, argc);
	//cJSON_AddItemToArray(a, skill);
	cJSON_AddItemToObject(jdata, "Attributes", a);

	p = cJSON_Print(jdata);

	/*

	f := RequestData{
	Company:         company,
	Tenant:          tenant,
	Class:           "CALLSERVER",
	Type:            "ARDS",
	Category:        "CALL",
	SessionId:       sessionid,
	RequestServerId: "1",
	Priority:        "L",
	OtherInfo:       "",
	Attributes:      skills,
	}

	*/
	//struct data_stream dstream = { NULL };

	//switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDSIZE, strlen(msg));
	//switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, (void *)msg);

	switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDSIZE, strlen(p));
	switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, (void *)p);


	headers = switch_curl_slist_append(headers, ct);
	headers = switch_curl_slist_append(headers, ctx);
	headers = switch_curl_slist_append(headers, cto);
	switch_safe_free(cto);
	switch_safe_free(ct);
	switch_safe_free(ctx);


	//switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "Post data: %s\n", data);

	switch_curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1);
	switch_curl_easy_setopt(curl_handle, CURLOPT_MAXREDIRS, 15);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
	switch_curl_easy_setopt(curl_handle, CURLOPT_URL, url);
	switch_curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);
	switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, file_callback);
	switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)http_data);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERFUNCTION, header_callback);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERDATA, (void *)http_data);
	switch_curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "freeswitch-curl/1.0");
	switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, headers);

	switch_curl_easy_perform(curl_handle);
	switch_curl_easy_getinfo(curl_handle, CURLINFO_RESPONSE_CODE, &httpRes);
	switch_curl_easy_cleanup(curl_handle);
	switch_curl_slist_free_all(headers);


	switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Add ARDS response is: %li\n", httpRes);
	if (httpRes == 200) {

		if (http_data->stream.data && !zstr((char *)http_data->stream.data) && strcmp(" ", http_data->stream.data)) {

			switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "ARDS respnse stream ok to proceed\n");
			
			http_data->http_response = switch_core_strdup(pool, http_data->stream.data);
			if ((cj = cJSON_Parse(http_data->http_response))) {

				for (cjp = cj->child; cjp; cjp = cjp->next) {
					char *name = cjp->string;
					//char *value = cjp->valuestring;
					
					switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Add ARDS response iteration: %s\n", name);

					if (name) {

						
						if (!strcasecmp(name, "Result") && cjp->type == cJSON_Object) {
							
							switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "ARDS respnse Result ok to proceed\n");
			

							for (cjr = cjp->child; cjr; cjr = cjr->next) {

								char *namex = cjr->string;

								switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Add ARDS response second iteration: %s\n", namex);
						
								if (!strcasecmp(namex, "Position")) {

									int valuex = cjr->valueint;
									switch_channel_set_variable_printf(channel, "ards_queue_position", "%d", valuex);
									
									switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "ARDS respnse Position set %d\n", valuex);
			
								}
								else if (!strcasecmp(namex, "QueueName")) {

									char *valuex = cjr->valuestring;
									switch_channel_set_variable(channel, "ards_skill_display", valuex);
									
									switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "ARDS respnse QueueName set %s\n", valuex);

								}
							}
						}
						else if (!strcasecmp(name, "isSuccess") && cjp->type == cJSON_False) {
							status = SWITCH_STATUS_FALSE;
						}
					}
				}
			}


			http_data->http_response_code = httpRes;

			switch_safe_free(http_data->stream.data);

			if (http_data && http_data->headers) {
				switch_curl_slist_free_all(http_data->headers);
			}

			if (pool) {
				switch_core_destroy_memory_pool(&pool);
			}

			switch_safe_free(p);
			cJSON_Delete(jdata);
			jdata = NULL;

			if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, ARDS_EVENT) == SWITCH_STATUS_SUCCESS) {
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Action", "ards-added");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-UUID", uuid);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-Skill", skill);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Company", com);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Tenant", ten);
				switch_event_add_header(event, SWITCH_STACK_BOTTOM, "ARDS-Event-Time", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ServerType", "CALLSERVER");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "RequestType", "CALL");
				switch_event_fire(&event);
			}

			cJSON_Delete(cj);
		}
		else {
			status = SWITCH_STATUS_FALSE;
		}


	}else {

		status = SWITCH_STATUS_FALSE;
	}
	
	switch_safe_free(com);
	switch_safe_free(ten);
	switch_safe_free(mycmd);

	return status;
}

static void send_notification(const char* event, const char* uuid, int company, int tenant, const char* resourceid, const char *message) {

	const char *url = globals.nurl;
	switch_memory_pool_t *pool = NULL;
	switch_CURL *curl_handle = NULL;
	http_data_t *http_data = NULL;
	switch_curl_slist_t *headers = NULL;
	//const char *data = NULL;
	//switch_curl_slist_t *headers = NULL;
	long httpRes = 0;
	cJSON *jdata;
	//	cJSON *a;

	//char tmpurl[1000];
	//	char msg[1000];
	char *p = "{}";

	char *ct = switch_mprintf("Content-Type: %s", "application/json");
	char *cto = switch_mprintf("companyinfo: %d:%d", tenant, company);
	char *ctx = switch_mprintf("authorization: Bearer %s", globals.security_token);
	char *cev = switch_mprintf("eventname: %s", event);
	char *cuuid = switch_mprintf("eventuuid: %s", uuid);


	//	switch_event_t *event;

	switch_core_new_memory_pool(&pool);
	curl_handle = switch_curl_easy_init();

	http_data = switch_core_alloc(pool, sizeof(http_data_t));
	memset(http_data, 0, sizeof(http_data_t));
	http_data->pool = pool;

	http_data->max_bytes = 64000;
	SWITCH_STANDARD_STREAM(http_data->stream);

	jdata = cJSON_CreateObject();
	cJSON_AddStringToObject(jdata, "To", resourceid);
	cJSON_AddNumberToObject(jdata, "Timeout", 1000);
	cJSON_AddStringToObject(jdata, "Direction", "STATELESS");
	cJSON_AddStringToObject(jdata, "Message", message);
	cJSON_AddStringToObject(jdata, "From", "CALLSERVER");
	cJSON_AddStringToObject(jdata, "Callback", "");
	p = cJSON_Print(jdata);
	switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDSIZE, strlen(p));
	switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, (void *)p);


	headers = switch_curl_slist_append(headers, ct);
	headers = switch_curl_slist_append(headers, ctx);
	headers = switch_curl_slist_append(headers, cto);
	headers = switch_curl_slist_append(headers, cev);
	headers = switch_curl_slist_append(headers, cuuid);
	switch_safe_free(cev);
	switch_safe_free(cuuid);
	switch_safe_free(cto);
	switch_safe_free(ct);
	switch_safe_free(ctx);

	//switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "Post data: %s\n", data);

	switch_curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1);
	switch_curl_easy_setopt(curl_handle, CURLOPT_MAXREDIRS, 15);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
	switch_curl_easy_setopt(curl_handle, CURLOPT_URL, url);
	switch_curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);
	switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, file_callback);
	switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)http_data);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERFUNCTION, header_callback);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERDATA, (void *)http_data);
	switch_curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "freeswitch-curl/1.0");
	switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, headers);

	switch_curl_easy_perform(curl_handle);
	switch_curl_easy_getinfo(curl_handle, CURLINFO_RESPONSE_CODE, &httpRes);
	switch_curl_easy_cleanup(curl_handle);
	switch_curl_slist_free_all(headers);

	if (http_data->stream.data && !zstr((char *)http_data->stream.data) && strcmp(" ", http_data->stream.data)) {

		http_data->http_response = switch_core_strdup(pool, http_data->stream.data);
	}

	http_data->http_response_code = httpRes;
	switch_safe_free(http_data->stream.data);

	if (http_data && http_data->headers) {
		switch_curl_slist_free_all(http_data->headers);
	}

	if (pool) {
		switch_core_destroy_memory_pool(&pool);
	}

	switch_safe_free(p);
	cJSON_Delete(jdata);
	jdata = NULL;
}

static void register_ards(int company, int tenant) {

	//const char *url = globals.url;
	const char *registerurl = globals.registerurl;
	switch_memory_pool_t *pool = NULL;
	switch_CURL *curl_handle = NULL;
	http_data_t *http_data = NULL;
	switch_curl_slist_t *headers = NULL;
	//const char *data = NULL;
	//switch_curl_slist_t *headers = NULL;
	long httpRes = 0;
	cJSON *jdata;

	//char tmpurl[1000];
	//char *msg;
	char *callback;
	char *queue_position_url;

	char *p = "{}";

	char *ct = switch_mprintf("Content-Type: %s", "application/json");
	char *ctx = switch_mprintf("authorization: Bearer %s", globals.security_token);

	switch_core_new_memory_pool(&pool);
	curl_handle = switch_curl_easy_init();

	http_data = switch_core_alloc(pool, sizeof(http_data_t));
	memset(http_data, 0, sizeof(http_data_t));
	http_data->pool = pool;

	http_data->max_bytes = 64000;
	SWITCH_STANDARD_STREAM(http_data->stream);


	//switch_snprintf(tmpurl, sizeof(tmpurl), "%s/add", registerurl);
	callback = switch_mprintf( "%s/ards_route", globals.rpc_url);
	queue_position_url = switch_mprintf("%s/ards_position", globals.rpc_url);


	/*

	Company:     1,
	Tenant:      3,
	Class:       "CALLSERVER",
	Type:        "ARDS",
	Category:    "CALL",
	CallbackUrl: callbakURL,
	ServerID:    1,

	*/

	//switch_snprintf(msg, sizeof(msg), "%d|%d|CALLSERVER|ARDS|CALL|%s|%d", company, tenant, callback, 1);


	jdata = cJSON_CreateObject();
	cJSON_AddNumberToObject(jdata, "Company", company);
	cJSON_AddNumberToObject(jdata, "Tenant", tenant);
	cJSON_AddStringToObject(jdata, "ServerType", "CALLSERVER");
	cJSON_AddStringToObject(jdata, "CallbackOption", "GET");
	cJSON_AddStringToObject(jdata, "CallbackUrl", callback);
	cJSON_AddStringToObject(jdata, "RequestType", "CALL");
	cJSON_AddTrueToObject(jdata, "ReceiveQueuePosition");
	cJSON_AddStringToObject(jdata, "QueuePositionCallbackUrl", queue_position_url);
	cJSON_AddStringToObject(jdata, "ServerID", globals.id);
	p = cJSON_Print(jdata);



	/*

	f := RequestData{
	Company:         company,
	Tenant:          tenant,
	Class:           "CALLSERVER",
	Type:            "ARDS",
	Category:        "CALL",
	SessionId:       sessionid,
	RequestServerId: "1",
	Priority:        "L",
	OtherInfo:       "",
	Attributes:      skills,
	}

	*/


	//switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDSIZE, strlen(msg));
	//switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, (void *)msg);

	switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDSIZE, strlen(p));
	switch_curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, (void *)p);


	headers = switch_curl_slist_append(headers, ct);
	headers = switch_curl_slist_append(headers, ctx);
	switch_safe_free(ct);
	switch_safe_free(ctx);
	//switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "Post data: %s\n", data);

	switch_curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1);
	switch_curl_easy_setopt(curl_handle, CURLOPT_MAXREDIRS, 15);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
	switch_curl_easy_setopt(curl_handle, CURLOPT_URL, registerurl);
	switch_curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);
	switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, file_callback);
	switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)http_data);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERFUNCTION, header_callback);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, headers);
	switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERDATA, (void *)http_data);
	switch_curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "freeswitch-curl/1.0");

	switch_curl_easy_perform(curl_handle);
	switch_curl_easy_getinfo(curl_handle, CURLINFO_RESPONSE_CODE, &httpRes);
	switch_curl_easy_cleanup(curl_handle);
	switch_curl_slist_free_all(headers);

	if (http_data->stream.data && !zstr((char *)http_data->stream.data) && strcmp(" ", http_data->stream.data)) {

		http_data->http_response = switch_core_strdup(pool, http_data->stream.data);
	}

	http_data->http_response_code = httpRes;

	switch_safe_free(http_data->stream.data);
	switch_safe_free(callback);
	switch_safe_free(queue_position_url);

	if (http_data && http_data->headers) {
		switch_curl_slist_free_all(http_data->headers);
	}

	if (pool) {
		switch_core_destroy_memory_pool(&pool);
	}



	switch_safe_free(p);
	cJSON_Delete(jdata);
	jdata = NULL;


}

SWITCH_STANDARD_APP(queue_music_function)
{
	switch_channel_t *channel = switch_core_session_get_channel(session);
	//const char *url = globals.qurl;
	switch_memory_pool_t *pool = NULL;
	switch_CURL *curl_handle = NULL;
	http_data_t *http_data = NULL;
	switch_curl_slist_t *headers = NULL;
	long httpRes = 0;
	char *ctx;
	char *tmpurl;
	//char *uuid = switch_core_session_get_uuid(session);

	const char *profile = switch_channel_get_variable(channel, "ards_profile");

	if (profile) {
		

		tmpurl = switch_mprintf( "%s/plain/Profile/%s", globals.qurl, profile);
		//AgentGreeting/:name/:language


		switch_core_new_memory_pool(&pool);
		curl_handle = switch_curl_easy_init();

		http_data = switch_core_alloc(pool, sizeof(http_data_t));
		memset(http_data, 0, sizeof(http_data_t));
		http_data->pool = pool;

		http_data->max_bytes = 64000;
		SWITCH_STANDARD_STREAM(http_data->stream);


		ctx = switch_mprintf("authorization: Bearer %s", globals.security_token);
		headers = switch_curl_slist_append(headers, ctx);
		switch_safe_free(ctx);


		//struct data_stream dstream = { NULL };
		//switch_curl_easy_setopt(curl_handle, CURLOPT_CUSTOMREQUEST, "DELETE");
		switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPGET, 1);
		switch_curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1);
		switch_curl_easy_setopt(curl_handle, CURLOPT_MAXREDIRS, 15);
		switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
		switch_curl_easy_setopt(curl_handle, CURLOPT_URL, tmpurl);
		switch_curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);
		switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, file_callback);
		switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, headers);
		switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)http_data);
		switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERFUNCTION, header_callback);
		switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERDATA, (void *)http_data);
		switch_curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "freeswitch-curl/1.0");

		switch_curl_easy_perform(curl_handle);
		switch_curl_easy_getinfo(curl_handle, CURLINFO_RESPONSE_CODE, &httpRes);
		switch_curl_easy_cleanup(curl_handle);
		switch_curl_slist_free_all(headers);

		if (http_data->stream.data && !zstr((char *)http_data->stream.data) && strcmp(" ", http_data->stream.data)) {

			http_data->http_response = switch_core_strdup(pool, http_data->stream.data);
		}

		http_data->http_response_code = httpRes;




		if (httpRes == 200) {

			if (!zstr(http_data->stream.data)) {

				char *mydata = NULL, *argv[4] = { 0 };

				mydata = strdup(http_data->stream.data);
				switch_assert(mydata);
				//int argc = switch_separate_string(mydata, ':', argv, (sizeof(argv) / sizeof(argv[0])));
				switch_channel_set_variable(channel, "ards_hold_music", argv[0]);
				switch_channel_set_variable(channel, "ards_first_announcement", argv[1]);
				switch_channel_set_variable(channel, "ards_announcement", argv[2]);
				switch_channel_set_variable(channel, "ards_announcement_time", argv[3]);
				switch_safe_free(mydata);

			}

		}

		switch_safe_free(http_data->stream.data);
		switch_safe_free(tmpurl);

		if (http_data && http_data->headers) {
			switch_curl_slist_free_all(http_data->headers);
		}

		if (pool) {
			switch_core_destroy_memory_pool(&pool);
		}
	}



	//switch_channel_set_variable(channel, "cc_last_agent_tier_level", agent_tier_level);

	return;

}

SWITCH_STANDARD_APP(ards_function)
{
	//switch_snprintf(tmpurl, sizeof(tmpurl), "%s/%s", url, uuid);

	char dbuf[10];
	char* music_file_path;
	switch_input_args_t args = { 0 };
	switch_channel_t *channel = switch_core_session_get_channel(session);
	char *uuid = switch_core_session_get_uuid(session);
	const char *music = "silence";
	switch_event_t *event;
	const char *tmp = switch_channel_get_variable(channel, "ards_hold_music");
	const char *firstannouncement = switch_channel_get_variable(channel, "ards_first_announcement");
	const char *announcement = switch_channel_get_variable(channel, "ards_announcement");
	const char *announcement_time = switch_channel_get_variable(channel, "ards_announcement_time");
	const char *max_queue_time = switch_channel_get_variable(channel, "ards_max_queue_time");
	const char *position_announcement = switch_channel_get_variable(channel, "ards_position_announcement");
	const char *position = switch_channel_get_variable(channel, "ards_queue_position");
	const char *position_language = switch_channel_get_variable(channel, "ards_position_language");
	switch_time_t t_queue_added = 0;
	ards_moh_step moh_step = ARDS_PRE_MOH;
	int time_a = 0;
	long time_m = 0;
	switch_bool_t queue_max_reached = SWITCH_FALSE;
	switch_status_t pstatus;
	const char *skill = NULL;
	const char *priority = NULL;
	const char *company = NULL;
	const char *tenant = NULL;
	const char *bussinessunit = NULL;
	char *mydata = NULL, *argv[5];

	if (!position_language) {
		position_language = "en";
	}

	if (announcement_time) {
		time_a = atoi(announcement_time);
	}

	if (max_queue_time) {
		time_m = atol(max_queue_time);
	}

	if (position_announcement && !strcasecmp(position_announcement, "true")) {
	}


	mydata = strdup(data);
	switch_separate_string(mydata, ',', argv, (sizeof(argv) / sizeof(argv[0])));
	switch_safe_free(mydata);

	//const char *priority = NULL;
	skill = switch_channel_get_variable(channel, "ards_skill");
	priority = switch_channel_get_variable(channel, "ards_priority");
	company = switch_channel_get_variable(channel, "companyid");
	tenant = switch_channel_get_variable(channel, "tenantid");
	bussinessunit = switch_channel_get_variable(channel, "business_unit");


	switch_channel_set_variable(channel, "dvp_call_type", "ards");
	switch_channel_set_variable(channel, "hangup_after_bridge", "false");
	
	switch_channel_answer(channel);

	if (!skill) {
		if (argv[0]) { skill = argv[0]; }
		else {
			skill = "111111";
		}
	}
	if (!company) {
		if (argv[2]) {
			company = argv[2];
		}
		else {
			company = "1";
		}
	}

	if (!tenant) {
		if (argv[1]) {
			tenant = argv[1];
		}
		else {
			tenant = "1";
		}
	}
	if (!bussinessunit) {

		bussinessunit = "default";
	}

	if (add_ards(atoi(company), atoi(tenant), skill, uuid, channel, priority, bussinessunit) == SWITCH_STATUS_SUCCESS) {

		position = switch_channel_get_variable(channel, "ards_queue_position");
		t_queue_added = local_epoch_time_now(NULL);
		switch_channel_set_variable_printf(channel, "ards_added", "%" SWITCH_TIME_T_FMT, t_queue_added);


		if (position_announcement && !strcasecmp(position_announcement, "true") && position) {

			moh_step = ARDS_POSITION_ANNOUNCEMENT;
		}
		else if (firstannouncement) {
			moh_step = ARDS_PRE_MOH;
		}
		else {
			moh_step = ARDS_MOH;
		}

		if (music && !strcasecmp(music, "silence")) {
			//music = "silence_stream://-1";
			//switch_snprintf(music_file_path, sizeof(music_file_path), "silence_stream://-1");
			music_file_path = switch_mprintf("%s", "silence_stream://-1");
		}

		args.input_callback = ards_on_dtmf;
		args.buf = dbuf;
		args.buflen = sizeof(dbuf);

		while (switch_channel_ready(channel)) {


			if (time_m > 0 && ((long)local_epoch_time_now(NULL) - (long)t_queue_added) > time_m) {
				queue_max_reached = SWITCH_TRUE;
				break;
			}
			////////////////////////////////////////////////////////////////////////////////
			if (moh_step == ARDS_PRE_MOH) {

				//music = firstannouncement;
				//switch_snprintf(music_file_path, sizeof(music_file_path), "%s/%s/%s/%s", globals.durl, tenant, company, firstannouncement);

				music_file_path = switch_mprintf("%s/%s/%s/%s", globals.durl, tenant, company, firstannouncement);

			}
			else if (moh_step == ARDS_MOH)
			{
				//music = tmp;
				if (!tmp) {

					tmp = switch_channel_get_hold_music(channel);
					//switch_snprintf(music_file_path, sizeof(music_file_path), tmp);

					music_file_path = switch_mprintf("%s", tmp);
				}
				else {
					if (time_a > 0) {

						//char music_path[1000];
						//switch_snprintf(music_file_path, sizeof(music_file_path), "{timeout=%d}%s/%s/%s/%s", time_a, globals.durl, tenant, company, tmp);

						music_file_path = switch_mprintf("{timeout=%d}%s/%s/%s/%s", time_a, globals.durl, tenant, company, tmp);
						//tmp = music_path;
					}
					else {

						//char music_path[1000];
						//switch_snprintf(music_file_path, sizeof(music_file_path), "%s/%s/%s/%s", globals.durl, tenant, company, tmp);
						//tmp = music_path;

						music_file_path = switch_mprintf("%s/%s/%s/%s", globals.durl, tenant, company, tmp);

					}
				}
			}
			else if (moh_step == ARDS_MOH_ANNOUNCEMENT)
			{
				//music = announcement;
				//switch_snprintf(music_file_path, sizeof(music_file_path), "%s/%s/%s/%s", globals.durl, tenant, company, announcement);
				music_file_path = switch_mprintf("%s/%s/%s/%s", globals.durl, tenant, company, announcement);
			}
			else if (moh_step == ARDS_POSITION_ANNOUNCEMENT || moh_step == ARDS_REPEAT_POSITION_ANNOUNCEMENT) {

				//char music_path[1000];
				position = switch_channel_get_variable(channel, "ards_queue_position");
				//switch_snprintf(music_file_path, sizeof(music_file_path), "phrase:queue_position:%s", position);
				//music = music_path;
				music_file_path = switch_mprintf("phrase:queue_position:%s", position);

			}
			else {

				music_file_path = switch_mprintf("%s", "silence_stream://-1");
			}

			///////////////////////////////////////////////////////////////////////////////
			pstatus = switch_ivr_play_file(session, NULL, music_file_path, &args);
			switch_safe_free(music_file_path);


			if (moh_step == ARDS_POSITION_ANNOUNCEMENT) {
				if (firstannouncement) {
					moh_step = ARDS_PRE_MOH;

				}
				else {
					moh_step = ARDS_MOH;
				}

			}
			else if (moh_step == ARDS_PRE_MOH) {

				moh_step = ARDS_MOH;
			}
			else if (moh_step == ARDS_MOH) {

				if (announcement && time_a > 0) {
					moh_step = ARDS_MOH_ANNOUNCEMENT;
				}
				else if (position_announcement && time_a > 0 && !strcasecmp(position_announcement, "true") && position) {

					moh_step = ARDS_REPEAT_POSITION_ANNOUNCEMENT;
				}
			}
			else if (moh_step == ARDS_MOH_ANNOUNCEMENT) {

				if (position_announcement && !strcasecmp(position_announcement, "true") && position) {

					moh_step = ARDS_REPEAT_POSITION_ANNOUNCEMENT;
				}
				else {
					moh_step = ARDS_MOH;
				}
			}
			else if (moh_step == ARDS_REPEAT_POSITION_ANNOUNCEMENT) {
				moh_step = ARDS_MOH;
			}

			if (pstatus == SWITCH_STATUS_BREAK || pstatus == SWITCH_STATUS_TIMEOUT) {
				break;
			}
		}


		if (!switch_channel_up(channel)) {

			switch_core_session_hupall_matching_var("ards_client_uuid", uuid, SWITCH_CAUSE_ORIGINATOR_CANCEL);
			Inform_ards(ARDS_RING_REJECTED, uuid, "reject", atoi(company), atoi(tenant));
			switch_channel_set_variable_printf(channel, "ards_queue_left", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));

			if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, ARDS_EVENT) == SWITCH_STATUS_SUCCESS) {
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Action", "client-left");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-UUID", uuid);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Company", company);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Tenant", tenant);
				switch_event_add_header(event, SWITCH_STACK_BOTTOM, "ARDS-Event-Time", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ServerType", "CALLSERVER");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "RequestType", "CALL");
				switch_event_fire(&event);
			}
		}
		else {


			if (queue_max_reached) {

				switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_DEBUG, "Left queue after maximum waiting");
			}

			Inform_ards(ARDS_COMPLETED, uuid, "routed", atoi(company), atoi(tenant));

			switch_channel_set_variable_printf(channel, "ards_queue_left", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
			switch_channel_set_variable_printf(channel, "ards_routed", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));

			if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, ARDS_EVENT) == SWITCH_STATUS_SUCCESS) {
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Action", "ards-routed");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-UUID", uuid);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Company", company);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Tenant", tenant);
				switch_event_add_header(event, SWITCH_STACK_BOTTOM, "ARDS-Event-Time", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ServerType", "CALLSERVER");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "RequestType", "CALL");
				switch_event_fire(&event);
			}
			//Inform_ards(ARDS_REMOVE, "TEST", "TEST");

		}

	}
	else
	{
		//////////////////////////////////////////////check for queue left///////////////////////////////////////////////////////////
		switch_core_session_hupall_matching_var("ards_client_uuid", uuid, SWITCH_CAUSE_ORIGINATOR_CANCEL);
		Inform_ards(ARDS_RING_REJECTED, uuid, "reject", atoi(company), atoi(tenant));
		switch_channel_set_variable_printf(channel, "ards_queue_left", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));

		if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, ARDS_EVENT) == SWITCH_STATUS_SUCCESS) {
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Action", "client-left");
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-UUID", uuid);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Company", company);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Tenant", tenant);
			switch_event_add_header(event, SWITCH_STACK_BOTTOM, "ARDS-Event-Time", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ServerType", "CALLSERVER");
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "RequestType", "CALL");
			switch_event_fire(&event);
		}

	}


	return;
}

static void *SWITCH_THREAD_FUNC outbound_agent_thread_run(switch_thread_t *thread, void *obj)
{
	struct call_helper *h = (struct call_helper *) obj;
	char *dialstr = NULL;
	switch_status_t status = SWITCH_STATUS_FALSE;
	switch_core_session_t *agent_session = NULL;
	switch_call_cause_t cause = SWITCH_CAUSE_NONE;
	switch_event_t *ovars;
	switch_bool_t agent_found = SWITCH_FALSE;
	switch_channel_t *member_channel = NULL;
	switch_channel_t *agent_channel = NULL;
	const char *cid_name = NULL;
	const char *engagement_type = "call";
	const char *channel_name = NULL;
	const char *cid_number = NULL;
	const char *skill = NULL;
	const char *caller_name = NULL;
	const char *caller_number = NULL;
	const char *calling_number = NULL;
	const char *dial_time = NULL;
	const char *p;
	switch_event_t *event;
	char *expandedx;
	char* msg;
	char* ardsfeatures;
	char* ardsoutboundfeatures;
	char* ardsoutivrfeatures;

	//char* agentGreeting;
	const char* company = h->company;
	const char* tenant = h->tenant;
	switch_bind_flag_t bind_flags = 0;
	switch_core_session_t *member_session;
	switch_channel_timetable_t *times = NULL;
	int kval = switch_dtmftoi("3");
	int rval = switch_dtmftoi("6");
	int ival = switch_dtmftoi("9");
	char start_epoch[64];

	switch_memory_pool_t *pool = NULL;
	switch_CURL *curl_handle = NULL;
	http_data_t *http_data = NULL;
	switch_curl_slist_t *headers = NULL;
	long httpRes = 0;
	char *ctn;
	char *cto;
	char *tmpurl;
	char *music_file_path;
	time_t when;
	int time_d = 30;
	//bind_flags |= SBF_DIAL_ALEG;

	bind_flags |= SBF_DIAL_BLEG;
	bind_flags |= SBF_EXEC_SAME;



	//////////////////////////////////////////////route to agent //////////////////////////////////////////////////


	member_session = switch_core_session_locate(h->member_uuid);

	if (member_session) {


		////////////////////////////////////////////////////////ARDS Key bind////////////////////////////////////////////////
		/*
		switch_bind_flag_t bind_flags = 0;
		int kval = switch_dtmftoi("3");
		bind_flags |= SBF_DIAL_BLEG;


		if (switch_ivr_bind_dtmf_meta_session(member_session, kval, bind_flags, "execute_extension::att_xfer XML PBXFeatures") != SWITCH_STATUS_SUCCESS) {

		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, "Bind Error!\n");
		}

		*/

		////////////////////////////////////////////////////////////////////////////////////////////////////////////


		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_DEBUG, "OutBound Started");

		member_channel = switch_core_session_get_channel(member_session);

		if ((p = switch_channel_get_variable(member_channel, "ards_agent_found")) && (agent_found = switch_true(p))) {}

		if (agent_found) {
			switch_core_destroy_memory_pool(&h->pool);
			return NULL;
		}

		switch_channel_set_variable(member_channel, "ards_agent_found", "true");
		switch_channel_set_variable(member_channel, "ards_skill_display", h->skills);

		skill = switch_channel_get_variable(member_channel, "ards_skill");
		caller_name = switch_channel_get_variable(member_channel, "caller_id_name");
		caller_number = switch_channel_get_variable(member_channel, "caller_id_number");
		calling_number = switch_channel_get_variable(member_channel, "destination_number");
		dial_time = switch_channel_get_variable(member_channel, "ards_dial_time");

		if (dial_time) {
			time_d = atoi(dial_time);
		}


		if (!(cid_name = switch_channel_get_variable(member_channel, "effective_caller_id_name"))) {
			cid_name = caller_name;
		}
		if (!(cid_number = switch_channel_get_variable(member_channel, "effective_caller_id_number"))) {
			cid_number = caller_number;
		}

		if ((channel_name = switch_channel_get_variable(member_channel, "channel_name")) && strstr(channel_name, "@sip.skype.com")) {
			engagement_type = "skype";
		}


		//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_DEBUG, "Setting channel name to: %s\n", strstr(channel_name, "@sip.skype.com"));
		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_DEBUG, "Setting outbound caller_id_name to: %s\n", cid_name);
		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_DEBUG, "Setting outbound caller_id_number to: %s\n", cid_number);
		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_INFO, "Setting channel name to: %s\n", channel_name);

		switch_event_create(&ovars, SWITCH_EVENT_REQUEST_PARAMS);
		//////add necessory event details/////////////////////////////////

		switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "ards_client_uuid", "%s", h->member_uuid);
		switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "companyid", "%s", h->company);
		switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "tenantid", "%s", h->tenant);
		switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "ards_servertype", "%s", h->servertype);
		switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "ards_requesttype", "%s", h->requesttype);
		switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "ards_resource_id", "%s", h->resource_id);
		switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "ards_resource_name", "%s", h->resource_name);
		switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "business_unit", "%s", h->business_unit);

		
		switch_channel_process_export(member_channel, NULL, ovars, "ards_export_vars");



		if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, ARDS_EVENT) == SWITCH_STATUS_SUCCESS) {

			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Agent", h->originate_string);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Action", "agent-found");
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-UUID", h->member_uuid);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-Skill", skill);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Caller-Number", caller_number);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Caller-Name", caller_name);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Calling-Number", calling_number);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Id", h->resource_id);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Name", h->resource_name);
			//switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "ards_resource_name", "%s", h->resource_name);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Company", company);
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Tenant", tenant);
			switch_event_add_header(event, SWITCH_STACK_BOTTOM, "ARDS-Event-Time", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ServerType", "CALLSERVER");
			switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "RequestType", "CALL");
			switch_event_fire(&event);

		}

		msg = switch_mprintf("agent_found|%q|%q|%q|%q|%q|%q|inbound|%q|%q", h->member_uuid, skill, cid_number, cid_name, calling_number, h->skills, engagement_type, h->profile_name);
		if (!zstr(h->profile_name)) {

			send_notification("agent_found", h->member_uuid, atoi(h->company), atoi(h->tenant), h->profile_name, msg);
		}
		switch_safe_free(msg);

		////////////////////////////////////////////////////setup url/////////////////////////////////////////////////////////////////////////////



		if (!strcasecmp(h->originate_type, "PRIVATE")) {

			//sip_h_X-User-to-User=48656c6c6f
			char *ctx = switch_mprintf("{sip_h_X-session=%s,memberuuid=%s,originate_timeout=%d,DVP_ACTION_CAT=DEFAULT,DVP_OPERATION_CAT=PRIVATE_USER}user/%s@%s", h->member_uuid, h->member_uuid, time_d, h->originate_user, h->originate_domain);
			h->originate_string = switch_core_strdup(h->pool, ctx);
			switch_safe_free(ctx);
		}
		else if (!strcasecmp(h->originate_type, "PUBLIC")) {

			char *ctx = switch_mprintf("{sip_h_X-session=%s,memberuuid=%s,DVP_ACTION_CAT=DEFAULT,DVP_OPERATION_CAT=PUBLIC_USER,sip_h_DVP-DESTINATION-TYPE=PUBLIC_USER}sofia/external/%s@%s", h->member_uuid, h->member_uuid, h->originate_user, h->originate_domain);
			switch_event_add_header(ovars, SWITCH_STACK_BOTTOM, "sip_h_DVP-DESTINATION-TYPE", "%s", "PUBLIC_USER");
			h->originate_string = switch_core_strdup(h->pool, ctx);
			switch_safe_free(ctx);


		}
		else if (!strcasecmp(h->originate_type, "TRUNK")) {

			char *ctx = switch_mprintf("{sip_h_X-session=%s,memberuuid=%s,DVP_ACTION_CAT=DEFAULT,DVP_OPERATION_CAT=GATEWAY,sip_h_DVP-DESTINATION-TYPE=GATEWAY}sofia/gateway/%s/%s", h->member_uuid, h->member_uuid, h->originate_domain, h->originate_user);
			h->originate_string = switch_core_strdup(h->pool, ctx);
			switch_safe_free(ctx);


		}
		else {

			char *ctx = switch_mprintf("{sip_h_X-session=%s,memberuuid=%s,originate_timeout=%d,DVP_ACTION_CAT=DEFAULT,DVP_OPERATION_CAT=PRIVATE_USER}user/%s@%s", h->member_uuid, h->member_uuid, time_d, h->originate_user, h->originate_domain);
			h->originate_string = switch_core_strdup(h->pool, ctx);
			switch_safe_free(ctx);

		}


		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


		dialstr = switch_channel_expand_variables(member_channel, h->originate_string);
		status = switch_ivr_originate(NULL, &agent_session, &cause, dialstr, time_d, NULL, cid_name ? cid_name : h->member_cid_name, cid_number ? cid_number : h->member_cid_number, NULL, ovars, SOF_NONE, NULL);
		if (dialstr != h->originate_string) {
			switch_safe_free(dialstr);
		}


		switch_event_destroy(&ovars);
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////



		if (status == SWITCH_STATUS_SUCCESS) {


			member_channel = switch_core_session_get_channel(member_session);
			agent_channel = switch_core_session_get_channel(agent_session);




			if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, ARDS_EVENT) == SWITCH_STATUS_SUCCESS) {
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Agent", h->originate_string);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Agent-UUID", switch_core_session_get_uuid(agent_session));
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Action", "agent-connected");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-UUID", h->member_uuid);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Id", h->resource_id);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Name", h->resource_name);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Company", company);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Tenant", tenant);
				switch_event_add_header(event, SWITCH_STACK_BOTTOM, "ARDS-Event-Time", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ServerType", "CALLSERVER");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "RequestType", "CALL");
				switch_event_fire(&event);
			}


			if (!zstr(h->profile_name)) {
				msg = switch_mprintf("agent_connected|%q|%q|%q|%q|%q|%q|inbound|%q|%q|%q", h->member_uuid, skill, cid_number, cid_name, calling_number, h->skills, engagement_type, h->profile_name, switch_core_session_get_uuid(agent_session));
				send_notification("agent_connected", h->member_uuid, atoi(h->company), atoi(h->tenant), h->profile_name, msg);
			}
			switch_safe_free(msg);

			switch_channel_set_variable(member_channel, "ARDS-Resource-Profile-Name", h->profile_name);
			switch_channel_set_variable(member_channel, "ARDS-Resource-Id", h->resource_id);
			switch_channel_set_variable(member_channel, "ARDS-Resource-Name", h->resource_name);
			switch_channel_set_variable(member_channel, "ARDS-SIP-Name", h->originate_display);



			////////////////////////////////////////////////////////ARDS Key bind////////////////////////////////////////////////

			ardsfeatures = switch_mprintf("execute_extension::att_xfer XML ARDSFeatures|%q|%q", tenant, company);

			switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, "Agent leg binding");
			if (switch_ivr_bind_dtmf_meta_session(member_session, kval, bind_flags, (const char*)ardsfeatures) != SWITCH_STATUS_SUCCESS) {

				switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, "Bind Error!\n");
			}

			ardsoutboundfeatures = switch_mprintf("execute_extension::att_xfer_outbound XML ARDSFeatures|%q|%q", tenant, company);

			switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, "Agent leg binding");
			if (switch_ivr_bind_dtmf_meta_session(member_session, rval, bind_flags, (const char*)ardsoutboundfeatures) != SWITCH_STATUS_SUCCESS) {

				switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, "Bind Error!\n");
			}


			ardsoutivrfeatures = switch_mprintf("execute_extension::att_xfer_ivr XML ARDSFeatures|%q|%q", tenant, company);

			switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, "Agent leg binding");
			if (switch_ivr_bind_dtmf_meta_session(member_session, ival, bind_flags, (const char*)ardsoutivrfeatures) != SWITCH_STATUS_SUCCESS) {

				switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, "Bind Error!\n");
			}

			//execute_on_answer=uuid_broadcast 336889f2-1868-11de-81a9-3f4acc8e505e sorry.wav both
			//switch_core_session_get_uuid(agent_session)
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//agentGreeting = switch_mprintf("uuid_broadcast %q sorry.wav both", switch_core_session_get_uuid(agent_session));
			//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, agentGreeting);
			//switch_channel_set_variable(agent_channel, "execute_on_answer", agentGreeting);

			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			switch_safe_free(ardsfeatures);
			switch_safe_free(ardsoutboundfeatures);
			switch_safe_free(ardsoutivrfeatures);
			//switch_safe_free(agentGreeting);




			///////////////////////////////////////////////////start recording//////////////////////////////////////////////////////
			if (!globals.rurl) {
				if (globals.recordPath) {
					char *expanded = switch_channel_expand_variables(member_channel, globals.recordPath);
					switch_channel_set_variable(member_channel, "ards_record_file", expanded);

					switch_ivr_record_session(member_session, expanded, 0, NULL);
					if (expanded != globals.recordPath) {
						switch_safe_free(expanded);
					}

					//<action application="set" data="exec_after_bridge_app=transfer"/>
					//<action application = "set" data = "exec_after_bridge_arg=2102" / >
					//<action application="stop_record_session" data="${record_file_name}"/>
					//switch_channel_set_variable(member_channel, "exec_after_bridge_app", stop_record_session);
					//switch_channel_set_variable(member_channel, "exec_after_bridge_arg", expanded);

					////////////////////////////////////////upload end of the session////////////////////////////////////////////


					if (globals.uurl) {
						//////check for memory leak/////////////////////////////////////////////
						char* uploaddata = switch_mprintf("curl_sendfile:%s/%s/%s file=%s class=CALLSERVER&type=CALL&category=CONVERSATION&mediatype=audio&filetype=mp3&referenceid=%s&display=%s-%s", globals.uurl, h->tenant, h->company, switch_channel_get_variable(member_channel, "ards_record_file"), h->member_uuid, caller_number, h->resource_name);
						//switch_snprintf(uploaddata, sizeof(uploaddata), "curl_sendfile:%s/%s/%s file=%s class=CALLSERVER&type=CALL&category=CONVERSATION&mediatype=audio&filetype=mp3&referenceid=%s&display=%s-%s", globals.uurl, h->tenant, h->company, switch_channel_get_variable(member_channel, "ards_record_file"), h->member_uuid, caller_number, h->resource_name);
						expandedx = switch_channel_expand_variables(member_channel, uploaddata);
						switch_channel_set_variable(member_channel, "record_post_process_exec_api", expandedx);

						if (expandedx != uploaddata) {
							switch_safe_free(expandedx);
						}
					}

				}
			}
			else {



				//////////////////////////////////////////////test webupload ////////////////////////////////////
				//<action application="record" data="http://(file=/tmp/part1.ul,name=part1.PCMU)example.net/part1.PCMU?rev=47"/>
				char* uploaddata = switch_mprintf("http://(file=%s.mp3)%s/%s/%s?class=CALLSERVER&type=CALL&category=CONVERSATION&referenceid=%s&mediatype=audio&filetype=mp3&sessionid=%s&display=%s-%s", h->member_uuid, globals.rurl, h->tenant, h->company, h->member_uuid, h->member_uuid, caller_number, h->resource_name);
				switch_ivr_record_session(member_session, uploaddata, 0, NULL);
				switch_safe_free(uploaddata);

				/////////////////////////////////////////////////////////////////////////////////////////////////////////////


			}

			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			switch_ivr_uuid_bridge(h->member_session_uuid, switch_core_session_get_uuid(agent_session));
			switch_channel_wait_for_flag(agent_channel, CF_BRIDGED, SWITCH_TRUE, 1000, NULL);


			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			ctn = switch_mprintf("authorization: Bearer %s", globals.security_token);
			cto = switch_mprintf("companyinfo: %d:%d", atoi(h->tenant), atoi(h->company));

			switch_core_new_memory_pool(&pool);
			curl_handle = switch_curl_easy_init();

			http_data = switch_core_alloc(pool, sizeof(http_data_t));
			memset(http_data, 0, sizeof(http_data_t));
			http_data->pool = pool;

			http_data->max_bytes = 64000;
			SWITCH_STANDARD_STREAM(http_data->stream);


			tmpurl = switch_mprintf("%s/AgentGreeting/%s/%s", globals.qurl, h->profile_name, switch_channel_get_variable(member_channel, "ards_position_language"));

			headers = switch_curl_slist_append(headers, ctn);
			switch_safe_free(ctn);

			headers = switch_curl_slist_append(headers, cto);
			switch_safe_free(cto);

			//struct data_stream dstream = { NULL };
			switch_curl_easy_setopt(curl_handle, CURLOPT_CUSTOMREQUEST, "GET");
			//switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPGET, 1);
			switch_curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1);
			switch_curl_easy_setopt(curl_handle, CURLOPT_MAXREDIRS, 15);
			switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPAUTH, CURLAUTH_ANY);

			switch_curl_easy_setopt(curl_handle, CURLOPT_URL, tmpurl);
			switch_curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);
			switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, file_callback);
			switch_curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)http_data);
			switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERFUNCTION, header_callback);
			switch_curl_easy_setopt(curl_handle, CURLOPT_HEADERDATA, (void *)http_data);
			switch_curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "freeswitch-curl/1.0");
			switch_curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, headers);

			switch_curl_easy_perform(curl_handle);
			switch_curl_easy_getinfo(curl_handle, CURLINFO_RESPONSE_CODE, &httpRes);
			switch_curl_easy_cleanup(curl_handle);
			switch_curl_slist_free_all(headers);

			if (http_data->stream.data && !zstr((char *)http_data->stream.data) && strcmp(" ", http_data->stream.data)) {

				http_data->http_response = switch_core_strdup(pool, http_data->stream.data);
			}

			http_data->http_response_code = httpRes;



			if (httpRes == 200) {

				if (!zstr(http_data->stream.data)) {

					char *mydata = strdup(http_data->stream.data);
					switch_assert(mydata);
					music_file_path = switch_mprintf("%s/%s/%s/%s", globals.durl, tenant, company, mydata);
					//status = switch_ivr_play_file(agent_session, NULL, music_file_path, NULL);
					//switch_ivr_broadcast(h->member_uuid, music_file_path, SMF_ECHO_ALEG | SMF_ECHO_BLEG);
					when = switch_epoch_time_now(NULL) + 2;
					switch_ivr_schedule_broadcast(when, h->member_uuid, music_file_path, SMF_ECHO_ALEG | SMF_ECHO_BLEG);
					//switch_ivr_broadcast(switch_core_session_get_uuid(agent_session), music_file_path, SMF_ECHO_BLEG);
					//switch_ivr_broadcast(switch_core_session_get_uuid(agent_session), music_file_path, SMF_ECHO_BLEG | SMF_ECHO_ALEG);

					switch_safe_free(mydata);
					switch_safe_free(music_file_path);

				}

			}


			switch_safe_free(tmpurl);

			switch_safe_free(http_data->stream.data);

			if (http_data && http_data->headers) {
				switch_curl_slist_free_all(http_data->headers);
			}

			if (pool) {
				switch_core_destroy_memory_pool(&pool);
			}




			/* Wait until the agent hangup.  This will quit also if the agent transfer the call */
			while (switch_channel_up(agent_channel) && globals.running) {
				if (!switch_channel_test_flag(agent_channel, CF_BRIDGED)) {

					break;
				}

				switch_yield(100000);
			}


			if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, ARDS_EVENT) == SWITCH_STATUS_SUCCESS) {
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Agent", h->originate_string);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Agent-UUID", switch_core_session_get_uuid(agent_session));
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Action", "agent-disconnected");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-UUID", h->member_uuid);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Id", h->resource_id);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Name", h->resource_name);
				switch_event_add_header(event, SWITCH_STACK_BOTTOM, "ARDS-Event-Time", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Company", company);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Tenant", tenant);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ServerType", "CALLSERVER");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "RequestType", "CALL");
				switch_event_fire(&event);
			}

			//msg = switch_mprintf("agent_disconnected|%q", h->member_uuid);
			//if (!zstr(h->profile_name))
			//send_notification("agent_disconnected", h->member_uuid, atoi(h->company), atoi(h->tenant), h->profile_name, msg);
			//switch_safe_free(msg);


			if (!zstr(h->profile_name)) {

				times = switch_channel_get_timetable(agent_channel);
				switch_snprintf(start_epoch, sizeof(start_epoch), "%" SWITCH_TIME_T_FMT, times->answered / 1000000);
				msg = switch_mprintf("agent_disconnected|%q|%q|%q|%q|%q|%q|inbound|%q|%q|%" SWITCH_TIME_T_FMT "|%ld", h->member_uuid, skill, cid_number, cid_name, calling_number, h->skills, engagement_type, h->profile_name, start_epoch, ((long)local_epoch_time_now(NULL) - atol(start_epoch)));
				send_notification("agent_disconnected", h->member_uuid, atoi(h->company), atoi(h->tenant), h->profile_name, msg);
				switch_safe_free(msg);
			}



			switch_channel_set_variable_printf(member_channel, "ards_route_left", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));


		}
		else {

			if (switch_channel_up(member_channel)) {


				Inform_ards(ARDS_REJECTED, h->member_uuid, switch_channel_cause2str(cause), atoi(h->company), atoi(h->tenant));
				switch_channel_set_variable(member_channel, "ards_agent_found", NULL);


				if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, ARDS_EVENT) == SWITCH_STATUS_SUCCESS) {
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Agent", h->originate_string);
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Action", "agent-rejected");
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-UUID", h->member_uuid);
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Id", h->resource_id);
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Name", h->resource_name);
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Reason", switch_channel_cause2str(cause));
					switch_event_add_header(event, SWITCH_STACK_BOTTOM, "ARDS-Event-Time", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Company", company);
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Tenant", tenant);
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ServerType", "CALLSERVER");
					switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "RequestType", "CALL");
					switch_event_fire(&event);
				}


				//msg = switch_mprintf("agent_rejected|%q", h->member_uuid);
				//if (!zstr(h->profile_name))
				//send_notification("agent_rejected", h->member_uuid, atoi(h->company), atoi(h->tenant), h->profile_name, msg);
				//switch_safe_free(msg);

				if (!zstr(h->profile_name)) {

					msg = switch_mprintf("agent_rejected|%q|%q|%q|%q|%q|%q|inbound|%q|%q|%" SWITCH_TIME_T_FMT "|%" SWITCH_TIME_T_FMT, h->member_uuid, skill, cid_number, cid_name, calling_number, h->skills, engagement_type, h->profile_name, local_epoch_time_now(NULL), local_epoch_time_now(NULL));
					send_notification("agent_rejected", h->member_uuid, atoi(h->company), atoi(h->tenant), h->profile_name, msg);
					switch_safe_free(msg);
				}


			}
			else {


				//Inform_ards(ARDS_RING_REJECTED, h->member_uuid, "reject", atoi(h->company), atoi(h->tenant));
				//switch_channel_set_variable(member_channel, "ards_agent_found", NULL);


				/*if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, ARDS_EVENT) == SWITCH_STATUS_SUCCESS) {
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Agent", h->originate_string);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Action", "ring-rejected");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Call-UUID", h->member_uuid);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Id", h->resource_id);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Resource-Name", h->resource_name);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ARDS-Reason", switch_channel_cause2str(cause));
				switch_event_add_header(event, SWITCH_STACK_BOTTOM, "ARDS-Event-Time", "%" SWITCH_TIME_T_FMT, local_epoch_time_now(NULL));
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Company", company);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "Tenant", tenant);
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "ServerType", "CALLSERVER");
				switch_event_add_header_string(event, SWITCH_STACK_BOTTOM, "RequestType", "CALL");
				switch_event_fire(&event);
				}
				*/

				if (!zstr(h->profile_name)) {

					msg = switch_mprintf("agent_rejected|%q|%q|%q|%q|%q|%q|inbound|%q|%q|%" SWITCH_TIME_T_FMT "|%" SWITCH_TIME_T_FMT, h->member_uuid, skill, cid_number, cid_name, calling_number, h->skills, engagement_type, h->profile_name, local_epoch_time_now(NULL), local_epoch_time_now(NULL));
					send_notification("agent_rejected", h->member_uuid, atoi(h->company), atoi(h->tenant), h->profile_name, msg);
					switch_safe_free(msg);
				}

			}

		}

	}
	else {

		Inform_ards(ARDS_EXPIRE, h->member_uuid, "nosession", atoi(h->company), atoi(h->tenant));
	}

	if (agent_session) {

		switch_core_session_rwunlock(agent_session);
	}
	if (member_session) {

		switch_core_session_rwunlock(member_session);

	}


	switch_core_destroy_memory_pool(&h->pool);
	return NULL;
}

SWITCH_STANDARD_API(ards_position_function) {


	char *mydata = NULL;
	switch_core_session_t *member_session = NULL;
	char *sessionid = NULL;
	char *queue = NULL;
	char *position = NULL;
	//int position = -1;
	//switch_status_t pstatus;
	switch_channel_t *channel = NULL;

	cJSON *cj, *cjp, *cjr;
	if (!globals.running) {
		return SWITCH_STATUS_FALSE;
	}
	if (zstr(cmd)) {
		stream->write_function(stream, "-USAGE: \n%s\n", "[<uuid>|<url>|<company>|<tenant>|<class>|<type>|<category>]");
		return SWITCH_STATUS_SUCCESS;
	}

	mydata = strdup(cmd);
	switch_assert(mydata);


	if ((cj = cJSON_Parse(mydata)) && cj->type == cJSON_Array) {

		for (cjp = cj->child; cjp; cjp = cjp->next) {

			switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_INFO, "Array loop started");

			for (cjr = cjp->child; cjr; cjr = cjr->next) {
				char *name = cjr->string;
				char *value = cjr->valuestring;

				switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_INFO, "Array Item loop started %s", name);

				if (name && value) {
					if (!strcasecmp(name, "SessionId")) {

						switch_strdup(sessionid, value);

					}
					else if (!strcasecmp(name, "QueueId")) {

						switch_strdup(queue, value);
					}

					else if (!strcasecmp(name, "QueuePosition")) {

						switch_strdup(position, value);
					}

				}
			}
			member_session = switch_core_session_locate(sessionid);

			if (member_session) {

				channel = switch_core_session_get_channel(member_session);
				if (channel) {
					switch_channel_set_variable_printf(channel, "ards_queue_position", "%s", position);
				}
				else {

					switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, "No channel found");
				}
			}
			else {

				switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_ERROR, "No session found");
			}


			switch_safe_free(sessionid);
			switch_safe_free(queue);

			if (member_session) {

				switch_core_session_rwunlock(member_session);

			}

		}



		/*
		while (switch_channel_ready(channel)) {
		pstatus = switch_ivr_phrase_macro(member_session, VM_MESSAGE_COUNT_MACRO, position, NULL, NULL);
		switch_channel_flush_dtmf(channel);

		if (pstatus == SWITCH_STATUS_BREAK || pstatus == SWITCH_STATUS_TIMEOUT) {
		break;
		}
		}*/
	}

	stream->write_function(stream, "+OK");


	cJSON_Delete(cj);
	switch_safe_free(mydata);


	return SWITCH_STATUS_SUCCESS;


}

SWITCH_STANDARD_API(ards_route_function)
{


	////////////////////////////////////////////////////////route thread start/////////////////////////////////////
	char *mydata = NULL;
	cJSON *cj, *cjp, *cjr;

	switch_thread_t *thread;
	switch_threadattr_t *thd_attr = NULL;
	switch_memory_pool_t *pool;
	struct call_helper *h;

	switch_core_new_memory_pool(&pool);
	h = switch_core_alloc(pool, sizeof(*h));
	h->pool = pool;



	if (!globals.running) {
		return SWITCH_STATUS_FALSE;
	}
	if (zstr(cmd)) {
		stream->write_function(stream, "-ERR : \n%s\n", "[<uuid>|<url>|<company>|<tenant>|<class>|<type>|<category>]");
		return SWITCH_STATUS_FALSE;
	}

	mydata = strdup(cmd);
	switch_assert(mydata);



	if ((cj = cJSON_Parse(mydata))) {


		for (cjp = cj->child; cjp; cjp = cjp->next) {
			char *name = cjp->string;
			char *value = cjp->valuestring;

			if (name && value) {
				if (!strcasecmp(name, "ServerType")) {

					h->servertype = switch_core_strdup(h->pool, value);

				}
				else if (!strcasecmp(name, "RequestType")) {

					h->requesttype = switch_core_strdup(h->pool, value);

				}

				else if (!strcasecmp(name, "Skills")) {

					h->skills = switch_core_strdup(h->pool, value);

				}
				

				else if (!strcasecmp(name, "BusinessUnit")) {

					h->business_unit = switch_core_strdup(h->pool, value);

				}

				else if (!strcasecmp(name, "SessionID")) {


					h->member_uuid = switch_core_strdup(h->pool, value);
					h->member_session_uuid = switch_core_strdup(h->pool, value);

				}
				else if (!strcasecmp(name, "Company")) {

					h->company = switch_core_strdup(h->pool, value);

				}
				else if (!strcasecmp(name, "Tenant")) {

					h->tenant = switch_core_strdup(h->pool, value);

				}


			}
			else {
				if (name && !strcasecmp(name, "ResourceInfo") && cjp->type == cJSON_Object) {

					for (cjr = cjp->child; cjr; cjr = cjr->next) {

						char *namex = cjr->string;
						char *valuex = cjr->valuestring;

						if (namex && valuex) {


							if (!strcasecmp(namex, "Extention")) {

								char *ctx = switch_mprintf("%s", valuex);
								h->originate_user = switch_core_strdup(h->pool, ctx);
								switch_safe_free(ctx);

							}
							else if (!strcasecmp(namex, "ContactType")) {

								
								h->originate_type = switch_core_strdup(h->pool, valuex);
							}
							else if (!strcasecmp(namex, "Domain")) {

								
								h->originate_domain = switch_core_strdup(h->pool, valuex);

							}
							else if (!strcasecmp(namex, "ContactName")) {

								
								h->originate_display = switch_core_strdup(h->pool, valuex);

							}
							else if (!strcasecmp(namex, "ResourceId")) {

								
								h->resource_id = switch_core_strdup(h->pool, valuex);

							}
							else if (!strcasecmp(namex, "ResourceName")) {

							
								h->resource_name = switch_core_strdup(h->pool, valuex);

							}
							else if (!strcasecmp(namex, "Profile")) {

								h->profile_name = switch_core_strdup(h->pool, valuex);

							}
						}
					}
				}
			}
		}


		////////////////////////////////////////////////////////plain text//////////////////////////////////////////////////////////////////////
		/*
		if (argc < 2) {
		stream->write_function(stream, "%s", "-ERR Invalid!\n");
		}
		else{

		uuid = argv[0];
		url = argv[1];
		if (argc > 2)
		company = argv[2];
		if (argc > 3)
		tenant = argv[3];
		if (argc > 4)
		resource_id = argv[4];
		if (argc > 5)
		class = argv[5];
		if (argc > 6)
		type = argv[6];
		if (argc > 7)
		category = argv[7];

		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



		if (!zstr(h->resource_name) && !zstr(h->resource_id) && !zstr(h->member_uuid) && !zstr(h->servertype) && !zstr(h->requesttype) && !zstr(h->company) && !zstr(h->tenant) && !zstr(h->originate_domain) && !zstr(h->originate_user) && !zstr(h->originate_type) && !zstr(h->originate_display) && !zstr(h->profile_name) && !zstr(h->skills)) {


			switch_threadattr_create(&thd_attr, h->pool);
			switch_threadattr_detach_set(thd_attr, 1);
			switch_threadattr_stacksize_set(thd_attr, SWITCH_THREAD_STACKSIZE);
			switch_thread_create(&thread, thd_attr, outbound_agent_thread_run, h, h->pool);

			stream->write_function(stream, "+OK ");

		}
		else
		{
			stream->write_function(stream, "-ERR No enough properties found");


		}

		cJSON_Delete(cj);


		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	}

	switch_safe_free(mydata);

	return SWITCH_STATUS_SUCCESS;
}

SWITCH_STANDARD_API(ards_url_test)
{

	Inform_ards(ARDS_REMOVE, "TEST", "TEST", 1, 1);


	return SWITCH_STATUS_SUCCESS;
}

/* Macro expands to: switch_status_t mod_ards_load(switch_loadable_module_interface_t **module_interface, switch_memory_pool_t *pool) */

SWITCH_MODULE_LOAD_FUNCTION(mod_ards_load)
{
	switch_application_interface_t *app_interface;
	switch_api_interface_t *api_interface;
	switch_status_t status;

	memset(&globals, 0, sizeof(globals));
	globals.pool = pool;

	switch_core_hash_init(&globals.ards_hash);
	switch_mutex_init(&globals.mutex, SWITCH_MUTEX_NESTED, globals.pool);

	if ((status = load_config()) != SWITCH_STATUS_SUCCESS) {
		return status;
	}

	switch_mutex_lock(globals.mutex);
	globals.running = 1;
	switch_mutex_unlock(globals.mutex);

	/* connect my internal structure to the blank pointer passed to me */
	*module_interface = switch_loadable_module_create_module_interface(pool, modname);


	SWITCH_ADD_APP(app_interface, "ards", "ards", "ardscc", ards_function, "queue", SAF_NONE);
	SWITCH_ADD_APP(app_interface, "ards_profile", "ards_profile", "ardscc_profilr", queue_music_function, "queue_music", SAF_NONE);
	SWITCH_ADD_API(api_interface, "ards_route", "Route to agent", ards_route_function, "[<uuid>,<url>,<company>,<tenant>,<class>,<type>,<category>]");
	SWITCH_ADD_API(api_interface, "ards_position", "Agent position", ards_position_function, "[<uuid>,<url>,<company>,<tenant>,<class>,<type>,<category>]");


	SWITCH_ADD_API(api_interface, "ards_url_test", "Test ards url", ards_url_test, "");


	register_ards(1, 1);


	/* indicate that the module should continue to be loaded */
	return SWITCH_STATUS_SUCCESS;
}

/*
Called when the system shuts down
Macro expands to: switch_status_t mod_ards_shutdown() */

SWITCH_MODULE_SHUTDOWN_FUNCTION(mod_ards_shutdown)
{

	//int sanity = 0;

	switch_mutex_lock(globals.mutex);
	if (globals.running == 1) {
		globals.running = 0;
	}
	switch_mutex_unlock(globals.mutex);

	/*while (globals.threads) {
	switch_cond_next();
	if (++sanity >= 60000) {
	break;
	}
	}*/

	switch_mutex_lock(globals.mutex);


	switch_safe_free(globals.url);
	switch_mutex_unlock(globals.mutex);
	return SWITCH_STATUS_SUCCESS;
}

/* For Emacs:
* Local Variables:
* mode:c
* indent-tabs-mode:t
* tab-width:4
* c-basic-offset:4
* End:
* For VIM:
* vim:set softtabstop=4 shiftwidth=4 tabstop=4 noet
*/
