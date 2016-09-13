# Part 2

In this post we will be extending the chat room to add a few more features:
 * Add the ability to "log in" with a desired user name.
 * Add the ability to join named chat rooms.
 * Instead of broadcasting messages to everyone, only broadcast messages to chat rooms.

Right now the server only supports a single action - broadcasting - so all messages from the client could be treated the same way. In part 2, we will need a slightly more sophisticated way for clients to interact with the server. So, the first step will be introducing a protocol using Google Protobufs.
