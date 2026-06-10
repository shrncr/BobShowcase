import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { Container, Grid, Image, Header, Segment, Loader, Message, Breadcrumb } from 'semantic-ui-react';
import CartBox from '../components/cart/CartBox';
import { paintingsService } from '../services/paintingsService';

const PaintingDetail = () => {
  const { id } = useParams();
  const [painting, setPainting] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadPainting();
  }, [id]);

  const loadPainting = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const data = await paintingsService.getPaintingById(id);
      setPainting(data);
    } catch (err) {
      console.error('Error loading painting:', err);
      setError('Painting not found');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Container style={{ marginTop: '2em' }}>
        <Segment basic textAlign="center" style={{ minHeight: '400px' }}>
          <Loader active inline="centered">Loading painting...</Loader>
        </Segment>
      </Container>
    );
  }

  if (error || !painting) {
    return (
      <Container style={{ marginTop: '2em' }}>
        <Message negative>
          <Message.Header>Error</Message.Header>
          <p>{error || 'Painting not found'}</p>
          <Link to="/paintings">Back to paintings</Link>
        </Message>
      </Container>
    );
  }

  const artistName = `${painting.firstName} ${painting.lastName}`.trim();

  return (
    <div>
      <Segment style={{ backgroundColor: '#F5F5F5', margin: 0, padding: '2em 0' }}>
        <Container>
          <Breadcrumb>
            <Breadcrumb.Section as={Link} to="/">Home</Breadcrumb.Section>
            <Breadcrumb.Divider />
            <Breadcrumb.Section as={Link} to="/paintings">Paintings</Breadcrumb.Section>
            <Breadcrumb.Divider />
            <Breadcrumb.Section active>{painting.title}</Breadcrumb.Section>
          </Breadcrumb>
          
          <Grid stackable style={{ marginTop: '2em' }}>
            <Grid.Column width={9}>
              <Image
                src={`/images/art/medium/${painting.imageFileName}.jpg`}
                size="big"
                alt={painting.title}
                style={{ cursor: 'pointer' }}
              />
            </Grid.Column>
            <Grid.Column width={7}>
              <div>
                <Header as="h2">{painting.title}</Header>
                <Header as="h3">{artistName}</Header>
                <p>{painting.excerpt}</p>
                
                {/* Painting Details */}
                <Segment>
                  <Header as="h4">Details</Header>
                  <p><strong>Year:</strong> {painting.yearOfWork}</p>
                  <p><strong>Medium:</strong> {painting.medium}</p>
                  <p><strong>Dimensions:</strong> {painting.width} x {painting.height} cm</p>
                  <p><strong>Gallery:</strong> {painting.galleryName}</p>
                </Segment>

                {/* Cart Box */}
                <CartBox painting={painting} />
              </div>
            </Grid.Column>
          </Grid>
        </Container>
      </Segment>

      {/* Description Section */}
      <Container style={{ marginTop: '2em', marginBottom: '2em' }}>
        <Segment>
          <Header as="h3">Description</Header>
          <p>{painting.description}</p>
          
          {painting.wikiLink && (
            <p>
              <a href={painting.wikiLink} target="_blank" rel="noopener noreferrer">
                Learn more on Wikipedia
              </a>
            </p>
          )}
          
          {painting.museumLink && (
            <p>
              <a href={painting.museumLink} target="_blank" rel="noopener noreferrer">
                View at {painting.galleryName}
              </a>
            </p>
          )}
        </Segment>
      </Container>
    </div>
  );
};

export default PaintingDetail;

// Made with Bob
