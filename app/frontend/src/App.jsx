import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import Hero from './components/Hero';
import RestaurantCard from './components/RestaurantCard';
import StatusBanner from './components/StatusBanner';

function App() {
  const [restaurants, setRestaurants] = useState([]);
  const [systemInfo, setSystemInfo] = useState({ version: 'loading...' });
  const [loading, setLoading] = useState(true);

  // In Kubernetes, the Ingress will route api.harshalpantawane.shop to the backend endpoint
  const API_BASE_URL = 'https://api.harshalpantawane.shop'; 


  useEffect(() => {
    // Fetch system info (Blue/Green version)
    fetch(`${API_BASE_URL}/info`)
      .then(res => res.json())
      .then(data => setSystemInfo(data))
      .catch(err => console.error("Could not connect to backend", err));

    // Fetch restaurants
    fetch(`${API_BASE_URL}/restaurants`)
      .then(res => res.json())
      .then(data => {
        setRestaurants(data);
        setLoading(false);
      })
      .catch(err => {
        console.error("Failed to fetch restaurants", err);
        // Fallback mock data for UI demonstration if backend isn't up
        setRestaurants([
          { id: 1, name: 'Spice Route', rating: 4.8, type: 'Indian' },
          { id: 2, name: 'Tokyo Drift Sushi', rating: 4.6, type: 'Japanese' },
          { id: 3, name: 'Burger Cartel', rating: 4.3, type: 'American' },
          { id: 4, name: 'La Dolce Vita', rating: 4.9, type: 'Italian' }
        ]);
        setLoading(false);
      });
  }, []);

  return (
    <div className="app-container">
      <Header />
      <Hero />

      {loading ? (
        <div style={{ textAlign: 'center', padding: '2rem' }}>Loading deliciousness...</div>
      ) : (
        <div className="restaurant-grid">
          {restaurants.map(rest => (
            <RestaurantCard key={rest.id} restaurant={rest} />
          ))}
        </div>
      )}

      <StatusBanner systemInfo={systemInfo} />
    </div>
  );
}

export default App;
