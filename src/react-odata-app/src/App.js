import React, { useState } from 'react';
import './App.css';
import turbopascal from './turbopascal.png';

function App() {
  const [businessPartners, setBusinessPartners] = useState([]);
  const [showList, setShowList] = useState(false);

  const fetchBusinessPartners = async () => {
    const response = await fetch('/api/sapbp/A_BusinessPartner?$top=10&$format=json');
    const data = await response.json();
    setBusinessPartners(data.d.results);
    setShowList(true);
  };

  const hideList = () => {
    setShowList(false);
  };

  return (
    <div className="App">
      <header className="App-header">
        <img src={turbopascal} className="App-logo" alt="turbopascal" />
        <h1 className="App-title">Business Partners from SAP ODATA</h1>
        {!showList && <button onClick={fetchBusinessPartners}>Show my Business Partners</button>}
        {showList && (
          <>
            <button onClick={hideList}>Hide Business Partners</button>
            <table>
              <thead>
                <tr>
                  <th>Business Partner</th>
                  <th>Business Partner Name</th>
                </tr>
              </thead>
              <tbody>
                {businessPartners.map((bp) => (
                  <tr key={bp.BusinessPartner}>
                    <td>{bp.BusinessPartner}</td>
                    <td>{bp.BusinessPartnerName}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </>
        )}
      </header>
    </div>
  );
}

export default App;