import { Item, Message } from 'semantic-ui-react';
import PaintingCard from './PaintingCard';

const PaintingGrid = ({ paintings }) => {
  if (paintings.length === 0) {
    return (
      <Message info>
        <Message.Header>No paintings found</Message.Header>
        <p>Try adjusting your filters to see more results.</p>
      </Message>
    );
  }

  return (
    <Item.Group divided>
      {paintings.map(painting => (
        <PaintingCard key={painting.paintingId} painting={painting} />
      ))}
    </Item.Group>
  );
};

export default PaintingGrid;

// Made with Bob
