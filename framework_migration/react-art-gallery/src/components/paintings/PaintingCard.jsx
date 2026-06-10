import { Item, Button, Icon } from 'semantic-ui-react';
import { Link } from 'react-router-dom';
import { useFavorites } from '../../hooks/useFavorites';
import { useCart } from '../../hooks/useCart';

const PaintingCard = ({ painting }) => {
  const { isFavorite, toggleFavorite } = useFavorites();
  const { addToCart } = useCart();
  const favorite = isFavorite(painting.paintingId);

  const handleFavoriteClick = (e) => {
    e.preventDefault();
    toggleFavorite(painting.paintingId);
  };

  const handleAddToCart = (e) => {
    e.preventDefault();
    addToCart(painting, { quantity: 1 });
  };

  const artistName = `${painting.firstName} ${painting.lastName}`.trim();

  return (
    <Item>
      <Item.Image
        as={Link}
        to={`/paintings/${painting.paintingId}`}
        size="small"
        src={`/images/art/square-medium/${painting.imageFileName}.jpg`}
        alt={painting.title}
      />
      <Item.Content>
        <Item.Header as={Link} to={`/paintings/${painting.paintingId}`}>
          {painting.title}
        </Item.Header>
        <Item.Meta>
          <span className="cinema">{artistName}</span>
        </Item.Meta>
        <Item.Description>
          <p>{painting.excerpt}</p>
        </Item.Description>
        <Item.Meta>
          <strong>${painting.msrp.toLocaleString()}</strong>
        </Item.Meta>
        <Item.Extra>
          <Button
            icon
            color="orange"
            onClick={handleAddToCart}
            title="Add to cart"
          >
            <Icon name="add to cart" />
          </Button>
          <Button
            icon
            color={favorite ? 'red' : undefined}
            onClick={handleFavoriteClick}
            title={favorite ? 'Remove from favorites' : 'Add to favorites'}
          >
            <Icon name={favorite ? 'heart' : 'heart outline'} />
          </Button>
        </Item.Extra>
      </Item.Content>
    </Item>
  );
};

export default PaintingCard;

// Made with Bob
