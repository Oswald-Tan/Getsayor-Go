import { io } from 'socket.io-client';

const SOCKET_URL = "http://localhost:8080";

export const initSocket = (token) => {
  return io(SOCKET_URL, {
    withCredentials: true,
    auth: { token },
    autoConnect: true,
    reconnection: true,
    reconnectionAttempts: 5,
    reconnectionDelay: 5000,
  });
};