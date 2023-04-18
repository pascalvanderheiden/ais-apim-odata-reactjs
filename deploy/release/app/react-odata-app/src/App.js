import { useState, useEffect } from 'react';
import logo from './logo.svg';
import './App.css';

function App() {
  const [businessPartners, setBusinessPartners] = useState([]);
  const [showBusinessPartners, setShowBusinessPartners] = useState(false);

  useEffect(() => {
    async function fetchBusinessPartners() {
      const response = await fetch('/api/sapbp/A_BusinessPartner?$top=10&$format=json');
      const data = await response.json();
      setBusinessPartners(data.d.results);
    }
    fetchBusinessPartners();
  }, []);

  function handleShowBusinessPartnersClick() {
    setShowBusinessPartners(true);
  }

  function handleHideBusinessPartnersClick() {
    setShowBusinessPartners(false);
  }

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        {!showBusinessPartners && (
          <button onClick={handleShowBusinessPartnersClick}>
            Show Business Partners
          </button>
        )}
        {showBusinessPartners && (
          <div>
            <button onClick={handleHideBusinessPartnersClick}>
              Hide Business Partners
            </button>
            <ul>
              {businessPartners.map((bp) => (
                <li key={bp.BusinessPartner}>
                  {bp.BusinessPartner} - {bp.BusinessPartnerFullName}
                </li>
              ))}
            </ul>
          </div>
        )}
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React, use ChatGPT
        </a>
      </header>
    </div>
  );
}

export default App;
