Todo API
These are the end points for this API.

A todo has the following format:

{
"id": "ca3084de-4424-4421-98af-0ae9e2cb3ee5",
"title": "Must pack bags",
"done": false
}
When creating a Todo you should not submit the id.
API key
All requests requires an API key. An API key uniquely identifies your Todo list. You can get an API key by using the /register endpoint.

GET /register
Get your API key

GET /todos?key=[YOUR API KEY]
List todos.

Will return an array of todos.

POST /todos?key=[YOUR API KEY]
Add todo.

Takes a Todo as payload (body). Remember to set the Content-Type header to application/json.

Will return the entire list of todos, including the added Todo, when successful.

PUT /todos/:id?key=[YOUR API KEY]
Update todo with :id

Takes a Todo as payload (body), and updates title and done for the already existing Todo with id in URL.

DELETE /todos/:id?key=[YOUR API KEY]
Deletes a Todo with id in URL
