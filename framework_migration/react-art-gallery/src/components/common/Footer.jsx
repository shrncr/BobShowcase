import { Segment, Container } from 'semantic-ui-react';

const Footer = () => {
  return (
    <Segment inverted vertical style={{ padding: '2em 0em', marginTop: '2em' }}>
      <Container textAlign="center">
        <p>&copy; 2024 Art Gallery. All rights reserved.</p>
      </Container>
    </Segment>
  );
};

export default Footer;

// Made with Bob
