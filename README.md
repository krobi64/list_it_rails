# ListIt: Rails
A shared list API

[//]: # (* Ruby version:) 

[//]: # (* System dependencies)

[//]: # (* Configuration)

[//]: # (* Database creation)

[//]: # (* Database initialization)

[//]: # (* How to run the test suite)

[//]: # (* Services - job queues, cache servers, search engines, etc.)

[//]: # (* Deployment instructions)

## API
All calls require a valid JWT **except**:
* POST /accounts
* POST /authenticate

The JWT token MUST be sent in the AUTHORIZATION header of the request.
```
headers["AUTHORIZATION"] = "token <JWT token value>"
```

If the token is invalid or missing, the system will return a 401 status with the following body:
```json
{
    "status": "error",
    "payload": {
      "token": "Missing token | Invalid token"
    }
}
```

All calls return the appropriate http status and a JSON body that contains the following:
* status: success | error
* payload: specific returned value | error list

### Create Account
```
POST /accounts
```
#### body
```json
{
    "email": "a valid email address",
    "password": "a valid password",
    "passord_confirmation": "a valid confirmation",
    "first_name": "an optional first name",
    "last_name": "an optional last_name"
}
```
* email (**required**): a valid email address
* password (**required**): a password that meets the following criteria:
    * at least 8 characters long
    * contains at least 1 upper case character
    * contains at least 1 lower case character
    * contains at least 1 numeric character
    * contains at least 1 special character
* password_confirmation (**required**): a re-typed in password value that MUST match password
* first_name (**optional**)
* last_name (**optional**)
#### results

##### success
* status 201
```json
{
   "status": "success",
   "payload": "<JWT token>"
} 
```
##### error
* status 422
```json
{
    "status": "error",
    "payload": {
        "base": "<Main error>",
        "<email|password>": "<field-specific error>"
    }
}
```

### Authenticate user
```
POST /authenticate
```
#### body
```json
{
    "email": "<User email>",
    "password": "<User password>"
}
```

#### responses
##### success
* status: 200
```json
{
   "status": "success",
   "payload": "<JWT token>"
} 
```
##### error
* status: 401
```json
{
    "status": "error",
    "payload": {
        "user_authentication": "invalid credentials"
    }
}
```
## Lists
### Create List
Creates a list owned by the current user.
```
POST /lists
```
#### body
```json
{
  "name": "List name"
}
```

#### responses
##### success
* Status: 201
* No body

##### error
* Status 422
```json
{
  "status": "error",
  "payload": {
      "name": ["can't be blank"]
  }
}
```

### Get Lists
Retrieves all lists owned by or shared with the current user. May return an empty list.
```
GET /lists
```

#### responses
##### success
* Status: 200
```json
[
      {
          "id": 1,
          "name": "List 1",
          "user": {
              "id": 1
          }
      },
      {
          "id": 23,
          "name": "List 2",
          "user": {
              "id": 3
          }
      } 
]
```

##### error
* Status 422

