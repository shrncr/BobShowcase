import { useState, useEffect } from 'react';
import { Container, Grid, Header, Loader, Segment } from 'semantic-ui-react';
import FilterPanel from '../components/filters/FilterPanel';
import PaintingGrid from '../components/paintings/PaintingGrid';
import { paintingsService } from '../services/paintingsService';

const BrowsePaintings = () => {
  const [paintings, setPaintings] = useState([]);
  const [filteredPaintings, setFilteredPaintings] = useState([]);
  const [filters, setFilters] = useState({
    artist: null,
    museum: null,
    shape: null
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadPaintings();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [filters, paintings]);

  const loadPaintings = async () => {
    try {
      const data = await paintingsService.getAllPaintings();
      setPaintings(data);
      setFilteredPaintings(data);
    } catch (error) {
      console.error('Error loading paintings:', error);
    } finally {
      setLoading(false);
    }
  };

  const applyFilters = () => {
    let filtered = [...paintings];

    if (filters.artist) {
      filtered = filtered.filter(p => p.artistId === parseInt(filters.artist));
    }
    if (filters.museum) {
      filtered = filtered.filter(p => p.galleryId === parseInt(filters.museum));
    }
    if (filters.shape) {
      filtered = filtered.filter(p => p.shapeId === parseInt(filters.shape));
    }

    setFilteredPaintings(filtered);
  };

  const handleFilterChange = (newFilters) => {
    setFilters({ ...filters, ...newFilters });
  };

  if (loading) {
    return (
      <Container style={{ marginTop: '2em' }}>
        <Segment basic textAlign="center" style={{ minHeight: '400px' }}>
          <Loader active inline="centered">Loading paintings...</Loader>
        </Segment>
      </Container>
    );
  }

  return (
    <Container style={{ marginTop: '2em', marginBottom: '2em' }}>
      <Grid stackable>
        <Grid.Column width={4}>
          <FilterPanel
            filters={filters}
            onFilterChange={handleFilterChange}
            paintings={paintings}
          />
        </Grid.Column>
        <Grid.Column width={12}>
          <Header as="h1">Paintings</Header>
          <Header.Subheader>
            {filteredPaintings.length} {filteredPaintings.length === 1 ? 'painting' : 'paintings'} found
          </Header.Subheader>
          <PaintingGrid paintings={filteredPaintings} />
        </Grid.Column>
      </Grid>
    </Container>
  );
};

export default BrowsePaintings;

// Made with Bob
