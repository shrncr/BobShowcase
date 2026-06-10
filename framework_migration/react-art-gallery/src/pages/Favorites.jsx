import { useState, useEffect } from 'react';
import { Container, Header, Table, Button, Icon, Segment, Message, Loader } from 'semantic-ui-react';
import { Link } from 'react-router-dom';
import { useFavorites } from '../hooks/useFavorites';
import { paintingsService } from '../services/paintingsService';

const Favorites = () => {
  const { favorites, removeFavorite, clearFavorites, isLoading: favoritesLoading } = useFavorites();
  const [favoritePaintings, setFavoritePaintings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadFavoritePaintings();
  }, [favorites]);

  const loadFavoritePaintings = async () => {
    if (favoritesLoading) return;
    
    setLoading(true);
    setError(null);
    
    try {
      const allPaintings = await paintingsService.getAllPaintings();
      const filtered = allPaintings.filter(p => 
        favorites.includes(p.paintingId)
      );
      setFavoritePaintings(filtered);
    } catch (err) {
      console.error('Error loading favorites:', err);
      setError('Failed to load favorites. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleRemove = (paintingId) => {
    removeFavorite(paintingId);
  };

  const handleClearAll = () => {
    if (window.confirm('Are you sure you want to remove all favorites?')) {
      clearFavorites();
    }
  };

  if (loading || favoritesLoading) {
    return (
      <Container style={{ marginTop: '2em' }}>
        <Segment basic textAlign="center" style={{ minHeight: '400px' }}>
          <Loader active inline="centered">Loading favorites...</Loader>
        </Segment>
      </Container>
    );
  }

  if (error) {
    return (
      <Container style={{ marginTop: '2em' }}>
        <Segment basic>
          <Message negative>
            <Message.Header>Error</Message.Header>
            <p>{error}</p>
          </Message>
        </Segment>
      </Container>
    );
  }

  return (
    <Container style={{ marginTop: '2em', marginBottom: '2em' }}>
      <Segment basic>
        <Header as="h2">
          <Icon name="heart" />
          <Header.Content>
            My Favorites
            <Header.Subheader>
              {favoritePaintings.length} {favoritePaintings.length === 1 ? 'painting' : 'paintings'}
            </Header.Subheader>
          </Header.Content>
        </Header>

        {favoritePaintings.length === 0 ? (
          <Message info>
            <Message.Header>No favorites yet</Message.Header>
            <p>
              Start adding paintings to your favorites! 
              <Link to="/paintings"> Browse paintings</Link>
            </p>
          </Message>
        ) : (
          <Table basic="very" collapsing>
            <Table.Header>
              <Table.Row>
                <Table.HeaderCell>Image</Table.HeaderCell>
                <Table.HeaderCell>Title</Table.HeaderCell>
                <Table.HeaderCell>Artist</Table.HeaderCell>
                <Table.HeaderCell>Price</Table.HeaderCell>
                <Table.HeaderCell>Action</Table.HeaderCell>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {favoritePaintings.map(painting => {
                const artistName = `${painting.firstName} ${painting.lastName}`.trim();
                return (
                  <Table.Row key={painting.paintingId}>
                    <Table.Cell>
                      <Link to={`/paintings/${painting.paintingId}`}>
                        <img
                          src={`/images/art/square-medium/${painting.imageFileName}.jpg`}
                          alt={painting.title}
                          style={{ width: '100px', height: '100px', objectFit: 'cover' }}
                        />
                      </Link>
                    </Table.Cell>
                    <Table.Cell>
                      <Link to={`/paintings/${painting.paintingId}`}>
                        <strong>{painting.title}</strong>
                      </Link>
                    </Table.Cell>
                    <Table.Cell>
                      {artistName}
                    </Table.Cell>
                    <Table.Cell>
                      ${painting.msrp.toLocaleString()}
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        size="small"
                        negative
                        onClick={() => handleRemove(painting.paintingId)}
                      >
                        <Icon name="trash" />
                        Remove
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table.Body>
            <Table.Footer fullWidth>
              <Table.Row>
                <Table.HeaderCell colSpan="5">
                  <Button
                    floated="left"
                    size="small"
                    primary
                    labelPosition="left"
                    icon
                    onClick={handleClearAll}
                  >
                    <Icon name="remove circle" />
                    Remove All Favorites
                  </Button>
                </Table.HeaderCell>
              </Table.Row>
            </Table.Footer>
          </Table>
        )}
      </Segment>
    </Container>
  );
};

export default Favorites;

// Made with Bob
