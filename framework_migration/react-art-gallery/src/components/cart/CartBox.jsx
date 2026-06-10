import { useState } from 'react';
import { Segment, Form, Button, Icon, Statistic, Dropdown, Message } from 'semantic-ui-react';
import { useCart } from '../../hooks/useCart';
import { useNavigate } from 'react-router-dom';
import FavoriteButton from '../favorites/FavoriteButton';

const CartBox = ({ painting }) => {
  const { addToCart } = useCart();
  const navigate = useNavigate();
  const [options, setOptions] = useState({
    quantity: 1,
    frame: 'None',
    glass: 'None',
    matt: 'None'
  });
  const [showSuccess, setShowSuccess] = useState(false);
  const [isAdding, setIsAdding] = useState(false);

  const frameOptions = [
    { key: 'none', text: 'None', value: 'None' },
    { key: 'wood', text: 'Wood Frame (+$50)', value: 'Wood' },
    { key: 'metal', text: 'Metal Frame (+$75)', value: 'Metal' },
    { key: 'ornate', text: 'Ornate Frame (+$150)', value: 'Ornate' }
  ];

  const glassOptions = [
    { key: 'none', text: 'None', value: 'None' },
    { key: 'standard', text: 'Standard Glass (+$25)', value: 'Standard' },
    { key: 'uv', text: 'UV Protection (+$50)', value: 'UV Protection' },
    { key: 'museum', text: 'Museum Quality (+$100)', value: 'Museum' }
  ];

  const mattOptions = [
    { key: 'none', text: 'None', value: 'None' },
    { key: 'white', text: 'White Matt (+$15)', value: 'White' },
    { key: 'black', text: 'Black Matt (+$15)', value: 'Black' },
    { key: 'cream', text: 'Cream Matt (+$15)', value: 'Cream' }
  ];

  const handleAddToCart = async () => {
    setIsAdding(true);
    
    try {
      addToCart(painting, options);
      setShowSuccess(true);
      
      // Hide success message after 3 seconds
      setTimeout(() => setShowSuccess(false), 3000);
    } catch (error) {
      console.error('Error adding to cart:', error);
      alert('Failed to add to cart. Please try again.');
    } finally {
      setIsAdding(false);
    }
  };

  const handleViewCart = () => {
    navigate('/cart');
  };

  return (
    <Segment>
      {showSuccess && (
        <Message positive>
          <Message.Header>Added to Cart!</Message.Header>
          <p>
            <Button size="mini" onClick={handleViewCart}>
              View Cart
            </Button>
          </p>
        </Message>
      )}

      <Form>
        <Statistic size="tiny">
          <Statistic.Value>${painting.msrp.toLocaleString()}</Statistic.Value>
          <Statistic.Label>Base Price</Statistic.Label>
        </Statistic>

        <Form.Group widths="equal" style={{ marginTop: '1em' }}>
          <Form.Field width={3}>
            <label>Quantity</label>
            <input
              type="number"
              min="1"
              max="10"
              value={options.quantity}
              onChange={(e) => setOptions({
                ...options,
                quantity: Math.max(1, Math.min(10, parseInt(e.target.value) || 1))
              })}
            />
          </Form.Field>

          <Form.Field width={4}>
            <label>Frame</label>
            <Dropdown
              selection
              options={frameOptions}
              value={options.frame}
              onChange={(e, { value }) => setOptions({ ...options, frame: value })}
            />
          </Form.Field>

          <Form.Field width={4}>
            <label>Glass</label>
            <Dropdown
              selection
              options={glassOptions}
              value={options.glass}
              onChange={(e, { value }) => setOptions({ ...options, glass: value })}
            />
          </Form.Field>

          <Form.Field width={4}>
            <label>Matt</label>
            <Dropdown
              selection
              options={mattOptions}
              value={options.matt}
              onChange={(e, { value }) => setOptions({ ...options, matt: value })}
            />
          </Form.Field>
        </Form.Group>
      </Form>

      <div style={{ marginTop: '1em' }}>
        <Button
          labelPosition="left"
          icon
          color="orange"
          onClick={handleAddToCart}
          loading={isAdding}
          disabled={isAdding}
          fluid
        >
          <Icon name="add to cart" />
          Add to Cart
        </Button>

        <div style={{ marginTop: '0.5em' }}>
          <FavoriteButton paintingId={painting.paintingId} labeled fluid />
        </div>
      </div>
    </Segment>
  );
};

export default CartBox;

// Made with Bob
