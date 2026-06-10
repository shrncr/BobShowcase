import { useState, useEffect } from 'react';
import { Form, Header, Button, Icon } from 'semantic-ui-react';
import { paintingsService } from '../../services/paintingsService';

const FilterPanel = ({ filters, onFilterChange }) => {
  const [artists, setArtists] = useState([]);
  const [museums, setMuseums] = useState([]);
  const [shapes, setShapes] = useState([]);

  useEffect(() => {
    loadFilterOptions();
  }, []);

  const loadFilterOptions = async () => {
    try {
      const [artistsData, museumsData, shapesData] = await Promise.all([
        paintingsService.getArtists(),
        paintingsService.getMuseums(),
        paintingsService.getShapes()
      ]);
      
      setArtists(artistsData);
      setMuseums(museumsData);
      setShapes(shapesData);
    } catch (error) {
      console.error('Error loading filter options:', error);
    }
  };

  const artistOptions = [
    { key: 0, text: 'Select Artist', value: null },
    ...artists.map(a => ({
      key: a.artistId,
      text: a.fullName,
      value: a.artistId
    }))
  ];

  const museumOptions = [
    { key: 0, text: 'Select Museum', value: null },
    ...museums.map(m => ({
      key: m.galleryId,
      text: m.galleryName,
      value: m.galleryId
    }))
  ];

  const shapeOptions = [
    { key: 0, text: 'Select Shape', value: null },
    ...shapes.map(s => ({
      key: s.shapeId,
      text: s.shapeName,
      value: s.shapeId
    }))
  ];

  const handleSubmit = (e) => {
    e.preventDefault();
    // Filters are already applied via onChange
  };

  const handleReset = () => {
    onFilterChange({ artist: null, museum: null, shape: null });
  };

  return (
    <Form onSubmit={handleSubmit}>
      <Header as="h3" dividing>Filters</Header>

      <Form.Field>
        <label>Artist</label>
        <Form.Select
          fluid
          options={artistOptions}
          value={filters.artist}
          onChange={(e, { value }) => onFilterChange({ artist: value })}
        />
      </Form.Field>

      <Form.Field>
        <label>Museum</label>
        <Form.Select
          fluid
          options={museumOptions}
          value={filters.museum}
          onChange={(e, { value }) => onFilterChange({ museum: value })}
        />
      </Form.Field>

      <Form.Field>
        <label>Shape</label>
        <Form.Select
          fluid
          options={shapeOptions}
          value={filters.shape}
          onChange={(e, { value }) => onFilterChange({ shape: value })}
        />
      </Form.Field>

      <Button 
        size="small" 
        color="orange" 
        type="button"
        onClick={handleReset}
      >
        <Icon name="redo" /> Reset Filters
      </Button>
    </Form>
  );
};

export default FilterPanel;

// Made with Bob
