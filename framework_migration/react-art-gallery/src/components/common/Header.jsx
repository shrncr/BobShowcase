import { Menu, Container, Dropdown, Icon, Label } from 'semantic-ui-react';
import { Link } from 'react-router-dom';
import { useFavorites } from '../../hooks/useFavorites';
import { useCart } from '../../hooks/useCart';

const Header = () => {
  const { favoritesCount } = useFavorites();
  const { cartCount } = useCart();

  return (
    <header>
      <Menu attached inverted stackable>
        <Container>
          <Menu.Menu position="right">
            <Dropdown item text="Account" icon="user">
              <Dropdown.Menu>
                <Dropdown.Item icon="sign in">Login</Dropdown.Item>
                <Dropdown.Item icon="edit">Edit Profile</Dropdown.Item>
                <Dropdown.Item icon="globe">Choose Language</Dropdown.Item>
                <Dropdown.Item icon="settings">Account Settings</Dropdown.Item>
              </Dropdown.Menu>
            </Dropdown>
            <Menu.Item as={Link} to="/favorites">
              <Icon name="heartbeat" />
              Favorites
              {favoritesCount > 0 && (
                <Label color="red" size="mini" style={{ marginLeft: '0.5em' }}>
                  {favoritesCount}
                </Label>
              )}
            </Menu.Item>
            <Menu.Item as={Link} to="/cart">
              <Icon name="shop" />
              Cart
              {cartCount > 0 && (
                <Label color="orange" size="mini" style={{ marginLeft: '0.5em' }}>
                  {cartCount}
                </Label>
              )}
            </Menu.Item>
          </Menu.Menu>
        </Container>
      </Menu>
      
      <Menu attached borderless stackable size="huge">
        <Container>
          <Menu.Item header as={Link} to="/">
            <img 
              src="/images/logo5.png" 
              alt="Art Gallery Logo" 
              className="ui small image" 
              style={{ marginRight: '1em' }}
            />
          </Menu.Item>
          <Menu.Item as={Link} to="/">
            <Icon name="home" />
            Home
          </Menu.Item>
          <Menu.Item>
            <Icon name="mail" />
            About Us
          </Menu.Item>
          <Menu.Item>
            <Icon name="home" />
            Blog
          </Menu.Item>
          <Dropdown item text="Browse" icon="grid layout">
            <Dropdown.Menu>
              <Dropdown.Item icon="users">Artists</Dropdown.Item>
              <Dropdown.Item icon="theme">Genres</Dropdown.Item>
              <Dropdown.Item as={Link} to="/paintings" icon="paint brush">
                Paintings
              </Dropdown.Item>
              <Dropdown.Item icon="cube">Subjects</Dropdown.Item>
            </Dropdown.Menu>
          </Dropdown>
          <Menu.Item position="right">
            <div className="ui mini icon input">
              <input type="text" placeholder="Search..." />
              <Icon name="search" />
            </div>
          </Menu.Item>
        </Container>
      </Menu>
    </header>
  );
};

export default Header;

// Made with Bob
