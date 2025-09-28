import { useContext } from 'react';
import { SidebarContext } from './sidebarContext'; 

// Hook untuk menggunakan SidebarContext
export const useSidebar = () => {
  return useContext(SidebarContext);
};
