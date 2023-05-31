import React, { useState } from 'react';
import './App.css';

function App() {
  const [businessPartners, setBusinessPartners] = useState([]);
  const [showList, setShowList] = useState(false);

  const handleShowList = () => {
    fetch('/api/sapbp/A_BusinessPartner?$top=10&$format=json')
      .then(response => response.json())
      .then(data => setBusinessPartners(data.d.results))
      .catch(error => console.log(error));
    setShowList(true);
  };

  const handleHideList = () => {
    setShowList(false);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>My Business Partners</h1>
        {showList ? (
          <div className="business-partners-grid">
            {businessPartners.map(businessPartner => (
              <div key={businessPartner.BusinessPartner} className="business-partner-card">
                <div className="business-partner-name">{businessPartner.BusinessPartnerFullName}</div>
                <div className="business-partner-id">{businessPartner.BusinessPartner}</div>
              </div>
            ))}
            <button onClick={handleHideList}>Hide List</button>
          </div>
        ) : (
          <button onClick={handleShowList}>Show my Business Partners</button>
        )}
      </header>
    </div>
  );
}

export default App;
