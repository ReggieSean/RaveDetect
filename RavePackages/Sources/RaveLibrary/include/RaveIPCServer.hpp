//
//  RaveIPCServer.hpp
//  
//
//  Created by SeanHuang on 11/13/24.
//

#ifndef RaveIPCServer_hpp
#define RaveIPCServer_hpp

//The steps involved in establishing a socket on the server side are as follows:
//
//Create a socket with the socket() system call
//Bind the socket to an address using the bind() system call. For a server socket on the Internet, an address consists of a port number on the host machine.
//Listen for connections with the listen() system call
//Accept a connection with the accept() system call. This call typically blocks until a client connects with the server.
//Send and receive data

class RaveIPCServer {
public:
    void create_socket();
    void bind_socket_to_address();
    void listen();
    void accept();
    void send();
    void receive();
private:
    
};
#endif /* RaveIPCServer_hpp */
