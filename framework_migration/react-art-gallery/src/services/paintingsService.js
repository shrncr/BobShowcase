// Service layer for paintings data
import { paintings } from '../data/paintings';

export const paintingsService = {
  // Get all paintings
  getAllPaintings: () => {
    return Promise.resolve([...paintings]);
  },

  // Get painting by ID
  getPaintingById: (id) => {
    const painting = paintings.find(p => p.paintingId === parseInt(id));
    if (!painting) {
      return Promise.reject(new Error('Painting not found'));
    }
    return Promise.resolve(painting);
  },

  // Filter paintings by criteria
  filterPaintings: (filters) => {
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

    return Promise.resolve(filtered);
  },

  // Get unique artists
  getArtists: () => {
    const artistsMap = new Map();
    paintings.forEach(p => {
      if (!artistsMap.has(p.artistId)) {
        artistsMap.set(p.artistId, {
          artistId: p.artistId,
          firstName: p.firstName,
          lastName: p.lastName,
          fullName: `${p.firstName} ${p.lastName}`.trim()
        });
      }
    });
    return Promise.resolve(Array.from(artistsMap.values()));
  },

  // Get unique museums/galleries
  getMuseums: () => {
    const museumsMap = new Map();
    paintings.forEach(p => {
      if (!museumsMap.has(p.galleryId)) {
        museumsMap.set(p.galleryId, {
          galleryId: p.galleryId,
          galleryName: p.galleryName
        });
      }
    });
    return Promise.resolve(Array.from(museumsMap.values()));
  },

  // Get unique shapes
  getShapes: () => {
    const shapesMap = new Map();
    paintings.forEach(p => {
      if (!shapesMap.has(p.shapeId)) {
        shapesMap.set(p.shapeId, {
          shapeId: p.shapeId,
          shapeName: `Shape ${p.shapeId}` // Could be enhanced with actual shape names
        });
      }
    });
    return Promise.resolve(Array.from(shapesMap.values()));
  }
};

export default paintingsService;

// Made with Bob
