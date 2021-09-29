# frozen_string_literal: true

require 'json'
require 'jwt'
require 'pp'

def main(event:, context:)  
  
  keys = event["headers"].keys
  contentType = "content-type"
  authorization = "authorization"

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
      token = event["headers"]["authorization"].split(" ")[1]    
      payload = JWT.decode(token, 'NOTASECRET')
    rescue

      response(body: nil, status: 403) 

    else

      # print "payload: "
      # print payload
      # print "\n\n\n"

      # print "expiry: "
      # print payload[0]["exp"]
      # print "\n\n\n"

      if Time.now.to_i > payload[0]["exp"]
        response(body: nil, status: 401)
      end

      response(body: payload[0]["data"], status: 200)
    end

    # case event["path"]
    # when "/"
    #   response(body: event, status: 403)
    # when "/token"
    #   response(body: event, status: 405)
    # else
    #   response(body: event, status: 404)
    # end

  # when "DELETE"
  #   case event["path"]
  #   when "/"
  #     response(body: event, status: 405)
  #   when "/token"
  #     response(body: event, status: 405)
  #   end
    
  # when "HEAD"
  #   case event["path"]
  #   when "/"
  #     response(body: event, status: 405)
  #   when "/token"
  #     response(body: event, status: 405)
  #   end  

  # when "OPTIONS"
  #   case event["path"]
  #   when "/"
  #     response(body: event, status: 405)
  #   when "/token"
  #     response(body: event, status: 405)
  #   end  

  # when "PATCH"
  #   case event["path"]
  #   when "/"
  #     response(body: event, status: 405)
  #   when "/token"
  #     response(body: event, status: 405)
  #   end  

  when "POST"

    if event["headers"]["content-type"] != "application/json"
      return response(body: nil, status: 415)
    end

    begin 
      
      JSON.parse(event["body"]) 
    
    rescue
      
      response(body: event, status: 422)
      
    else
      
      payload = {
        data: event["body"],
        exp: Time.now.to_i + 5,
        nbf: Time.now.to_i + 2
      }

      token = JWT.encode payload, ENV['JWT_SECRET'], 'HS256'

      response(body: {"token" => token}, status: 201) 

    end

    # case event["path"]
    # when "/"
    #   response(body: event, status: 405)
    # when "/token"
    #   case event["headers"]["content-type"]
    #   when ""
    #     response(body: event, status: 415)
    #   when "APPLICATION/JSON"
    #     response(body: event, status: 415)
    #   when "application/x-www-form-urlencoded"
    #     response(body: event, status: 415)
    #   when " "
    #     response(body: event, status: 415)
    #   when "text/plain"
    #     response(body: event, status: 415)
    #   when "multipart/form-data"
    #     response(body: event, status: 415)
    #   else

    #     begin 
    #       JSON.parse(event["body"]) 
    #     rescue
    #       response(body: event, status: 422)  
    #     end

      # end

    #end  


  # when "PUT"
  #   case event["path"]
  #   when "/"
  #     response(body: event, status: 405)
  #   when "/token"
  #     response(body: event, status: 405)
  #   end
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
                              'CONtent-Type' => 'application/json' },
               'httpMethod' => 'GET',
               'path' => '/'
             })
end