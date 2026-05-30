import React from 'react';
import { Utensils, Search, User } from 'lucide-react';

const Header = () => {
  return (
    <header className="header glass">
      <div className="logo">
        <Utensils color="#FF4757" />
        Zoma-Clone
      </div>
      <nav className="nav-links">
        <a href="#" className="nav-link"><Search size={20} /></a>
        <a href="#" className="nav-link"><User size={20} /></a>
      </nav>
    </header>
  );
};

export default Header;
