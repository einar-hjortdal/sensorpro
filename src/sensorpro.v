module sensorpro

import net.http
import json
import time

// https://sensorpro.eu/
// https://e.sensorpro.net/
// https://sensorpro.net/api/
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

fn (mut s Sensorpro) auth_sign_in() ! {
	endpoint := 'https://apinie.sensorpro.net/auth/sys/signin'
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
	data := json.decode(SensorproAuthSigninResponse, response.body)!
	s.expires_in = data.expires_in
	s.api_endpoint = data.api_endpoint
	s.token = data.token
}

fn (mut s Sensorpro) auth_log_off() ! {
	endpoint := '${s.api_endpoint}auth/sys/logoff/${s.token}'
	mut request := http.new_request(http.Method.post, endpoint, '')
	request.add_header(http.CommonHeader.content_type, 'application/json')
	request.do()!
	s.expires_in = time.now()
}
