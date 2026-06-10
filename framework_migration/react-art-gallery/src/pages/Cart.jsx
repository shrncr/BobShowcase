import { Container, Header, Table, Button, Icon, Segment, Message, Input, Divider } from 'semantic-ui-react';
import { Link } from 'react-router-dom';
import { useCart } from '../hooks/useCart';

const Cart = () => {
  const { 
    cartItems, 
    removeFromCart, 
    updateQuantity, 
    clearCart, 
    getCartTotal,
    getTotalItems,
    isLoading 
  } = useCart();

  const handleQuantityChange = (cartItemId, newQuantity) => {
    const quantity = parseInt(newQuantity);
    if (quantity > 0 && quantity <= 10) {
      updateQuantity(cartItemId, quantity);
    }
  };

  const handleRemove = (cartItemId) => {
    if (window.confirm('Remove this item from cart?')) {
      removeFromCart(cartItemId);
    }
  };

  const handleClearCart = () => {
    if (window.confirm('Are you sure you want to clear your entire cart?')) {
      clearCart();
    }
  };

  if (isLoading) {
    return (
      <Container style={{ marginTop: '2em' }}>
        <Segment basic textAlign="center" style={{ minHeight: '400px' }}>
          Loading cart...
        </Segment>
      </Container>
    );
  }

  if (cartItems.length === 0) {
    return (
      <Container style={{ marginTop: '2em' }}>
        <Segment basic textAlign="center">
          <Icon name="shopping cart" size="huge" color="grey" />
          <Header as="h2">Your cart is empty</Header>
          <p>Start adding paintings to your cart!</p>
          <Button as={Link} to="/paintings" primary>
            Browse Paintings
          </Button>
        </Segment>
      </Container>
    );
  }

  return (
    <Container style={{ marginTop: '2em', marginBottom: '2em' }}>
      <Segment basic>
        <Header as="h2">
          <Icon name="shopping cart" />
          <Header.Content>
            Shopping Cart
            <Header.Subheader>
              {getTotalItems()} {getTotalItems() === 1 ? 'item' : 'items'} in cart
            </Header.Subheader>
          </Header.Content>
        </Header>

        <Table celled striped>
          <Table.Header>
            <Table.Row>
              <Table.HeaderCell width={2}>Image</Table.HeaderCell>
              <Table.HeaderCell width={4}>Title</Table.HeaderCell>
              <Table.HeaderCell width={3}>Options</Table.HeaderCell>
              <Table.HeaderCell width={2}>Quantity</Table.HeaderCell>
              <Table.HeaderCell width={2}>Price</Table.HeaderCell>
              <Table.HeaderCell width={2}>Subtotal</Table.HeaderCell>
              <Table.HeaderCell width={1}>Action</Table.HeaderCell>
            </Table.Row>
          </Table.Header>

          <Table.Body>
            {cartItems.map(item => {
              const artistName = `${item.painting.firstName} ${item.painting.lastName}`.trim();
              return (
                <Table.Row key={item.id}>
                  <Table.Cell>
                    <Link to={`/paintings/${item.painting.paintingId}`}>
                      <img
                        src={`/images/art/square-medium/${item.painting.imageFileName}.jpg`}
                        alt={item.painting.title}
                        style={{ width: '80px', height: '80px', objectFit: 'cover' }}
                      />
                    </Link>
                  </Table.Cell>
                  <Table.Cell>
                    <Link to={`/paintings/${item.painting.paintingId}`}>
                      <strong>{item.painting.title}</strong>
                    </Link>
                    <div style={{ color: '#666', fontSize: '0.9em', marginTop: '0.25em' }}>
                      {artistName}
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <div style={{ fontSize: '0.9em' }}>
                      <div>Frame: {item.frame}</div>
                      <div>Glass: {item.glass}</div>
                      <div>Matt: {item.matt}</div>
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <Input
                      type="number"
                      min="1"
                      max="10"
                      value={item.quantity}
                      onChange={(e) => handleQuantityChange(item.id, e.target.value)}
                      style={{ width: '70px' }}
                    />
                  </Table.Cell>
                  <Table.Cell>
                    ${item.price.toLocaleString()}
                  </Table.Cell>
                  <Table.Cell>
                    <strong>${(item.price * item.quantity).toLocaleString()}</strong>
                  </Table.Cell>
                  <Table.Cell textAlign="center">
                    <Button
                      size="small"
                      negative
                      icon
                      onClick={() => handleRemove(item.id)}
                      title="Remove from cart"
                    >
                      <Icon name="trash" />
                    </Button>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table.Body>

          <Table.Footer>
            <Table.Row>
              <Table.HeaderCell colSpan="5" textAlign="right">
                <strong>Total:</strong>
              </Table.HeaderCell>
              <Table.HeaderCell>
                <strong style={{ fontSize: '1.2em' }}>
                  ${getCartTotal().toLocaleString()}
                </strong>
              </Table.HeaderCell>
              <Table.HeaderCell />
            </Table.Row>
          </Table.Footer>
        </Table>

        <Divider />

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Button
            size="small"
            onClick={handleClearCart}
          >
            <Icon name="trash" />
            Clear Cart
          </Button>

          <div>
            <Button as={Link} to="/paintings" size="large">
              Continue Shopping
            </Button>
            <Button primary size="large">
              <Icon name="payment" />
              Proceed to Checkout
            </Button>
          </div>
        </div>
      </Segment>
    </Container>
  );
};

export default Cart;

// Made with Bob
