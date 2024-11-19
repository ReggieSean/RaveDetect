//
//  RaveIPC.hpp
//  
//
//  Created by SeanHuang on 11/11/24.
//

#ifndef RaveIPCClient_hpp
#define RaveIPCClient_hpp


//The steps involved in establishing a socket on the client side are as follows:
//
//Create a socket with the socket() system call
//Connect the socket to the address of the server using the connect() system call
//Send and receive data. There are a number of ways to do this, but the simplest is to use the read() and write() system calls.

class RaveIPCClient{
public:
//    socket has domain(here is unix-domain) and type
//    The address of a socket in the Unix domain is a character string which is basically an entry in the file system.
//    In addition, each socket needs a port number on that host.
//    Port numbers are 16 bit unsigned integers.
//    The lower numbers are reserved in Unix for standard services.
//    port numbers above 2000 are generally available.

    void create_socket();
    void connect_socket();
    void send_buffer();
};


#endif /* RaveIPC_hpp */
