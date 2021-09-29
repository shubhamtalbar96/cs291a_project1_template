# frozen_string_literal: true

require 'json'
require 'jwt'
require 'pp'

def main(event:, context:)  
  
  case event["httpMethod"]
  when "GET"
    case event["path"]
    when "/"
      response(body: event, status: 403)
    when "/token"
      response(body: event, status: 405)
    else
      response(body: event, status: 404)
    end
  
  when "DELETE"
    case event["path"]
    when "/"
      response(body: event, status: 405)
    when "/token"
      response(body: event, status: 405)
    end
    
  when "HEAD"
    case event["path"]
    when "/"
      response(body: event, status: 405)
    when "/token"
      response(body: event, status: 405)
    end  

  when "OPTIONS"
    case event["path"]
    when "/"
      response(body: event, status: 405)
    when "/token"
      response(body: event, status: 405)
    end  

  when "PATCH"
    case event["path"]
    when "/"
      response(body: event, status: 405)
    when "/token"
      response(body: event, status: 405)
    end  

  when "POST"
    case event["path"]
    when "/"
      response(body: event, status: 405)
    when "/token"
      case event["Content-Type"]
      when ""
        response(body: event, status: 415)
      when "APPLICATION/JSON"
        response(body: event, status: 415)
      when "application/x-www-form-urlencoded"
        response(body: event, status: 415)
      when " "
        response(body: event, status: 415)
      when "text/plain"
        response(body: event, status: 415)
      end
    end  

  when "PUT"
    case event["path"]
    when "/"
      response(body: event, status: 405)
    when "/token"
      response(body: event, status: 405)
    end  
  end
end

def response(body: nil, status: 200)
  {
    body: body ? body.to_json + "\n" : '',
    statusCode: status
  }
end

if $PROGRAM_NAME == __FILE__
#   # If you run this file directly via `ruby function.rb` the following code
#   # will execute. You can use the code below to help you test your functions
#   # without needing to deploy first.
  ENV['JWT_SECRET'] = 'NOTASECRET'

  # Call /token
  PP.pp main(context: {}, event: {
               'body' => '{"name": "bboe"}',
               'headers' => { 'Content-Type' => 'application/json' },
               'httpMethod' => 'POST',
               'path' => '/token'
             })

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
                              'Content-Type' => 'application/json' },
               'httpMethod' => 'GET',
               'path' => '/'
             })
end