//
//  Header.h
//  RavePackages
//
//  Created by SeanHuang on 11/13/24.
//
// Umbrella header for indexing module map


#ifndef RaveLibrary_h
#define RaveLibrary_h

#include <stdio.h>
#define SOCKET_NAME "/tmp/raveipc.sock"
#define BUFFER_SIZE 2048

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <thread>
#include "RaveIPCClient.hpp"
#include "RaveIPCServer.hpp"



#endif /* Header_h */
