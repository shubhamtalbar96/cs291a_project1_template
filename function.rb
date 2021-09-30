# frozen_string_literal: true

require 'json'
require 'jwt'
require 'pp'

def main(event:, context:)  
  
  keys = event["headers"].keys

  for item in keys
    if item.casecmp?("content-type") 
      event["headers"]["content-type"] = event["headers"][item] 
    end

    if item.casecmp?("authorization")
      event["headers"]["authorization"] = event["headers"][item]
    end
  end

  # print "event: "
  # print event
  # print "\n\n"
  case event["httpMethod"]
  when "GET"
    begin 

      # print "event[path] : "
      # print event["path"]
      # print "\n\n"

      if event["path"] != "/token"
        return response(body: nil, status: 405)
      end

      if event["path"] != "/"
        return response(body: nil, status: 404)
      end

      token = event["headers"]["authorization"].split(" ")[1]    
      payload = JWT.decode(token, 'NOTASECRET')
    rescue
      return response(body: nil, status: 403) 
    else
      # print "payload: "
      # print payload
      # print "\n\n\n"

      # print "expiry: "
      # print payload[0]["exp"]
      # print "\n\n\n"

      if Time.now.to_i > payload[0]["exp"]
        return response(body: nil, status: 401)
      end
      
      return response(body: payload[0]["data"], status: 200)
    end
  when "POST"

    if event["path"] != "/"
      return response(body: nil, status: 405)
    end

    if event["headers"]["content-type"] != "application/json"
      return response(body: nil, status: 415)
    end

    begin 
      JSON.parse(event["body"]) 
    rescue
      return response(body: event, status: 422)
    else
      payload = {
        data: event["body"],
        exp: Time.now.to_i + 5,
        nbf: Time.now.to_i + 2
      }

      token = JWT.encode payload, ENV['JWT_SECRET'], 'HS256'

      return response(body: {"token" => token}, status: 201) 
    end
  else
    return response(body: nil, status: 405)
  end
end

def response(body: nil, status: 200)
  {
    body: body ? body.to_json + "\n" : '',
    statusCode: status
  }
end

if $PROGRAM_NAME == __FILE__
  # If you run this file directly via `ruby function.rb` the following code
  # will execute. You can use the code below to help you test your functions
  # without needing to deploy first.
  ENV['JWT_SECRET'] = 'NOTASECRET'

  # # Call /token
  # PP.pp main(context: {}, event: {
  #              'body' => '{"name": "bboe"}',
  #              'headers' => { 'Content-Type' => '' },
  #              'httpMethod' => 'POST',
  #              'path' => '/token'
  #            })

  # Generate a token
  payload = {
    data: { user_id: 128 },
    exp: Time.now.to_i + 1,
    nbf: Time.now.to_i
  }

  token = JWT.encode payload, ENV['JWT_SECRET'], 'HS256'
  # Call /
  PP.pp main(context: {}, event: {
               'headers' => { 'Authorization' => "Bearer #{token}",
                              'CONtent-Type' => 'application/json' },
               'httpMethod' => 'GET',
               'path' => '/fair-natured/certifiably/quietener'
             })
end