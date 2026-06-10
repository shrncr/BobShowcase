import { Button, Icon } from 'semantic-ui-react';
import { useFavorites } from '../../hooks/useFavorites';

const FavoriteButton = ({ 
  paintingId, 
  labeled = false, 
  size = 'medium',
  fluid = false 
}) => {
  const { isFavorite, toggleFavorite } = useFavorites();
  const favorite = isFavorite(paintingId);

  const handleClick = (e) => {
    e.preventDefault();
    toggleFavorite(paintingId);
  };

  return (
    <Button
      icon={!labeled}
      labelPosition={labeled ? 'right' : undefined}
      color={favorite ? 'red' : undefined}
      onClick={handleClick}
      size={size}
      fluid={fluid}
      title={favorite ? 'Remove from favorites' : 'Add to favorites'}
    >
      <Icon name={favorite ? 'heart' : 'heart outline'} />
      {labeled && (favorite ? 'Remove from Favorites' : 'Add to Favorites')}
    </Button>
  );
};

export default FavoriteButton;

// Made with Bob
