import { useState } from "react";
import { createRoot } from "react-dom/client";
import "./styles.css";

const features = [
  ["01", "One clear path", "Fund once, release once. No hidden state or moving goalposts."],
  ["02", "Time-bound by design", "Funds become releasable only at the timestamp encoded at deployment."],
  ["03", "Safety first", "Checks-effects-interactions and a reentrancy guard protect ETH transfers."],
];

function App() {
  const [copied, setCopied] = useState(false);
  const copyInstall = async () => {
    await navigator.clipboard?.writeText("forge test");
    setCopied(true);
    setTimeout(() => setCopied(false), 1800);
  };

  return (
    <main>
      <nav>
        <a className="brand" href="#top" aria-label="ChainVault home"><span>◈</span> ChainVault</a>
        <div className="nav-links"><a href="#how">How it works</a><a href="#security">Security</a></div>
        <a className="nav-button" href="https://github.com/tejaswikharade" target="_blank" rel="noreferrer">View code <b>↗</b></a>
      </nav>

      <section className="hero" id="top">
        <div className="glow glow-one" /><div className="glow glow-two" />
        <p className="eyebrow"><i /> ETH TIME-LOCK VAULT</p>
        <h1>Lock with intent.<br /><em>Release with certainty.</em></h1>
        <p className="hero-copy">A focused smart contract for time-bound ETH custody—built for transparent handoffs, milestones, and scheduled releases.</p>
        <div className="hero-actions"><a className="primary" href="#how">Explore the flow <span>↓</span></a><button className="ghost" onClick={copyInstall}>{copied ? "Copied ✓" : "forge test"}</button></div>
        <div className="vault-card" aria-label="Vault status preview">
          <div className="card-top"><span className="status"><i /> ACTIVE VAULT</span><span>Ethereum</span></div>
          <div className="amount">2.450 <small>ETH</small></div>
          <div className="card-rule" />
          <div className="vault-details"><div><span>Beneficiary</span><strong>0x71...b4F2</strong></div><div><span>Unlocks in</span><strong>14d 08h 31m</strong></div><div className="lock">⌁</div></div>
        </div>
        <p className="built">BUILT WITH <b>Solidity</b><b>Foundry</b><b>React</b></p>
      </section>

      <section className="flow" id="how">
        <div className="section-label">THE VAULT FLOW <span>— 01</span></div>
        <div className="flow-grid">
          {features.map(([number, title, body], index) => <article className="feature" key={title}><span className="number">{number}</span><span className="feature-icon">{["↳", "◷", "◇"][index]}</span><h2>{title}</h2><p>{body}</p></article>)}
        </div>
      </section>

      <section className="security" id="security">
        <div><p className="eyebrow"><i /> DESIGNED FOR CLARITY</p><h2>The rules stay<br /><em>on-chain.</em></h2></div>
        <div className="security-list">
          <p><span>01</span> Immutable beneficiary & unlock time</p>
          <p><span>02</span> Owner-only funding and pre-unlock cancellation</p>
          <p><span>03</span> Beneficiary-only post-unlock release</p>
          <p><span>04</span> Event trail for every material action</p>
        </div>
      </section>

      <footer><span>© 2026 CHAINVAULT</span><span>Built with deliberate constraints.</span><a href="#top">Back to top ↑</a></footer>
    </main>
  );
}

createRoot(document.getElementById("root")).render(<App />);
