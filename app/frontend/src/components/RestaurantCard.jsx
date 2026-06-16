import React from 'react';

const RestaurantCard = ({ restaurant }) => {
  return (
    <div className="restaurant-card glass">
      <div className="rating">★ {restaurant.rating}</div>
      <h3>{restaurant.name}</h3>
      <p>{restaurant.type || 'International'}</p>
    </div>
  );
};

export default RestaurantCard;
