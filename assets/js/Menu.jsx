import React, { Component } from 'react';

export default function(props) {
  const turn = () => {
    let ply = props.current == 1 ? props.player1 : props.player2;
    ply = (ply=="")?"-":ply;
    return ply;
  }
  // const listInfo = () => {
  //   return (
  //     <div>
  //       {_.map(props.info, (item, index) => <p key={index}>{item}</p >)}
  //     </div>
  //   )
  // }

  const player2 = () => {
    let player2 = props.player2;
    return (player2=="")?"None":player2;
  }

  const player1 = () => {
    let player1 = props.player1;
    return (player1=="")?"None":player1;
  }

  const userinfo = () => {
    if (props.player1 == play_cfg.user) {
      return "You Are Black"
    } else if (props.player2 == play_cfg.user) {
      return "You Are White"
    } else {
      return "You Are Observer"
    }
  }

  const threeButton = () => {
    if (props.player1 == play_cfg.user) {
      return (
        <div className="btn-pick">
          <button onClick={() => props.pickWhite()} className="pick-white btn btn-md btn-primary">Pick White</button>
          <button onClick={() => props.pickBlack()} className="pick-black btn btn-md btn-warning">Pick Black</button>
          <button onClick={() => props.observe()} className="pick-observer btn btn-md btn-primary">Observe</button>
        </div>
      )
    } else if (props.player2 == play_cfg.user) {
      return (
        <div className="btn-pick">
          <button onClick={() => props.pickWhite()} className="pick-white btn btn-md btn-warning">Pick White</button>
          <button onClick={() => props.pickBlack()} className="pick-black btn btn-md btn-primary">Pick Black</button>
          <button onClick={() => props.observe()} className="pick-observer btn btn-md btn-primary">Observe</button>
        </div>
      )
    } else {
      return (
        <div className="btn-pick">
          <button onClick={() => props.pickWhite()} className="pick-white btn btn-md btn-primary">Pick White</button>
          <button onClick={() => props.pickBlack()} className="pick-black btn btn-md btn-primary">Pick Black</button>
          <button onClick={() => props.observe()} className="pick-observer btn btn-md btn-warning">Observe</button>
        </div>
      )
    }
  }

  return (
    <div className="scores">
      <h3>{userinfo()}</h3>
      <br/><br/>
      <div className="role-pick-btns">{threeButton()}</div>
      <br/><br/>
      <div className="score-panel">
        <div className="score-panel-cnt-white">
          <p className="sword">{player2()}  &#9898;: {props.whiteScore}&nbsp;&nbsp;&nbsp;&nbsp;</p>
          <p className="sword">&#9876;</p>
          <p>{player1()}  &#9899;: {props.blackScore}&nbsp;&nbsp;&nbsp;&nbsp;</p >
        </div>
        <p>Current Player: {turn()}</p >
      </div>
      <button onClick={() => props.leave()} className="pick-observer btn btn-md btn-danger">Exit</button>
    </div>
  )
}
