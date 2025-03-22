module sensorpro

import net.http
import json
import time

// https://sensorpro.eu/
// https://e.sensorpro.net/
// https://sensorpro.net/api/

const api_root = 'https://apinie.sensorpro.net/'

pub struct SensorproOptions {
	api_key      string
	organization string
	user         string
	password     string
}

struct Sensorpro {
	SensorproOptions
mut:
	token        string
	expires_in   time.Time
	api_endpoint string
}

pub fn new_sensorpro(o SensorproOptions) Sensorpro {
	return Sensorpro{
		SensorproOptions: o
	}
}

fn (s Sensorpro) is_logged_in() bool {
	return s.token != '' && time.now() < s.expires_in
}

struct Result {
	request_id            string
	error_messages        []string
	status_messsages      []string
	total_status_messages int
	total_errors          int
}

// https://sensorpro.net/api/index.html#auth-signin
struct SensorproAuthSignin {
	organization string
	user         string
	password     string
}

struct SensorproAuthSigninResponse {
	Result
	expires_in   time.Time
	api_endpoint string
	token        string
}

fn (s Sensorpro) auth_sign_in() !SensorproAuthSigninResponse {
	endpoint := '${api_root}auth/sys/signin'
	header := 'x-apikey'
	body := SensorproAuthSignin{
		organization: s.organization
		user:         s.user
		password:     s.password
	}
	mut request := http.new_request(http.Method.post, endpoint, json.encode(body))
	request.add_header(http.CommonHeader.content_type, 'application/json')
	request.add_custom_header(header, s.api_key)!
	response := request.do()!
	return json.decode(SensorproAuthSigninResponse, response.body)!
}

fn (s Sensorpro) auth_log_off() ! {
	endpoint := '${api_root}auth/sys/logoff/${s.token}'
	mut request := http.new_request(http.Method.post, endpoint, '')
	request.add_header(http.CommonHeader.content_type, 'application/json')
	request.do()!
	return
}
