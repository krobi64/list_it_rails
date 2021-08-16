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
```http request
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
```http request
POST /accounts
```
#### body
```json
{
    "email": "a valid email address",
    "password": "a valid password",
    "passord_confirmation": "a valid confirmation",
    "first_name": "an optional first name",
    "last_name": "an optional last name"
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
* status 400
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
```http request
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
```http request
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
* Status 400
```json
{
  "status": "error",
  "payload": {
      "name": ["can't be blank"]
  }
}
```

### Get Lists
Retrieves all lists owned by or shared with the current user. Will return an empty array if no lists meet this criteria .
```http request
GET /lists
```

#### responses
##### success
* Status: 200
```json
{
  "status": "success",
  "payload": [
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
}
```

##### error
* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```

### Retrieve a Specific List
Returns a single list either owned by or shared with the current user.
```http request
GET /lists/:list_id
```
#### responses
##### success
* Status: 200
```json
{
  "status": "success",
  "payload": {
    "id": 1,
    "name": "List 1",
    "user": {
      "id": 1
    }
  }
}
```
##### error
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
    
}
```
### Edit List
Modify the name of an existing list owned by the current user.
```http request
PUT /lists/:list_id
```
#### body
```json
{
  "name": "New list name"
}
```
#### responses
##### success
* Status: 204
* No body

##### errors
* Status: 400
```json
{
  "status": "error",
  "payload": "Invalid Payload, refer to the api documentation"
}
```
or
* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```
or
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```

### Delete List
Delete a list the current user owns.
```http request
DELETE /lists/:list_id
```
#### responses
##### success
* Status: 204
* No body
##### errors
* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```
or
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```

```http request
```
#### body

```json
{
}
```
#### responses
##### success
```json
{
  "status": "success",
}
```
```json
{
}
```
```json
{
  "status": "error",
}
or
```
* Status: 401
```json
{
  "status": "error",
  "payload": "Unauthorized Access"
}
```
or
* Status: 404
```json
{
  "status": "error",
  "payload": "List not found"
}
```


