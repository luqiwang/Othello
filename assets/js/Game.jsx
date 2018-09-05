import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import { Button, Container, Col, Row, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap';
import _ from 'underscore';
import Tile from './Tile';
import Menu from './Menu'

// Global Constants
let TOP_LEFT  = 1;
let TOP    = 2;
let TOP_RIGHT  = 3;
let RIGHT   = 4;
let DOWN_RIGHT  = 5;
let DOWN   = 6;
let DOWN_LEFT  = 7;
let LEFT   = 8;
let SIZE = 8;

export default function run_game(root, channel) {
  ReactDOM.render(<Game channel={channel} />, root);
}

class Game extends Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;
    this.state = {
      tiles: [],
      availables: [],
      current: 0,
      blackScore: 0,
      whiteScore: 0,
      player1: "",
      player2: "",
      opaque: -1,
      end: false,
      noMove: ""
    }
    this.channel.join()
         .receive("ok", this.gotView.bind(this))
         .receive("error", resp => { console.log("Unable to join", resp) });
    this.channel.on("chess", state => this.funcA(state))
  }



  funcA (state) {
    this.setState(state, () => {
      if (state.end) {
        this.setState(state)
      }
      else {
        if (state.availables.length==0) {
            this.channel.push("chess", {"state": newState})
              .receive("ok", (resp) => {})
            return;
          }
          newState['current'] = oid
          this.channel.push("chess", {"state": newState})
            .receive("ok", (resp) => {})
        }
        else if (state.noMove != "") {
          setTimeout(() => { this.setState({noMove: ""}) }, 3000);
        }
      }
    })
  }


  getRes() {
      let res;
      if (this.state.blackScore > this.state.whiteScore) {
        res = "Black Win "
      } else if (this.state.blackScore < this.state.whiteScore) {
        res = "White Win"
      } else {
        res = "Tie"
      }
      res = res+" BlackScore:"+this.state.blackScore+" WhiteScore:"+this.state.whiteScore;
      return res;
    }

  gotView(view) {
    this.channel.push("chess", {"state": view.game.state})
        .receive("ok", (resp) => console.log("resp", resp))
    //this.setState(view.game.state)
  }

  game_again(){
    this.channel.push("restart", {state: this.state})
        .receive("ok", this.gotView.bind(this))
  }

  leave_room(){
     window.location = '/';
   }

   render() {
     let res = this.getRes();
     let noMove = this.state.noMove;
     return (
     <div className="container-container">
       <Container>
         <Row>
           <Col xs="12" lg="8">{this.renderTiles(this.state.tiles)}</Col>
           <Col xs="12" lg="4">
             <Menu current={this.state.current} player1={this.state.player1}
                player2={this.state.player2} blackScore={this.state.blackScore}
                whiteScore={this.state.whiteScore}
                pickWhite={this.pickWhite.bind(this)}
                pickBlack={this.pickBlack.bind(this)}
                observe={this.observe.bind(this)}
                leave={this.leave_room.bind(this)} />
           </Col>
         </Row>
       </Container>
       <div>
         <Modal isOpen={this.state.end}>
         <ModalHeader>Game Over</ModalHeader>
           <ModalBody>
             {res}
           </ModalBody>
           <ModalFooter>
             <Button color="primary" onClick={this.game_again.bind(this)}>Again</Button>{' '}
             <Button color="secondary" onClick={this.leave_room}>Leave</Button>
           </ModalFooter>
         </Modal>
       </div>
       <div>
         <Modal isOpen={noMove != ""}>
           <ModalHeader>Oops!</ModalHeader>
           <ModalBody>
             {noMove} Does Not Have Available Move!
           </ModalBody>
           <ModalFooter>
             <Button color="primary" onClick={this.continueGame.bind(this)}>Ok</Button>
           </ModalFooter>
         </Modal>

       </div>
     </div>
     )
    }

  continueGame() {
    this.setState({noMove: ""})
  }

  renderTiles(tiles) {
    return(
      <div className="tile-panel">
        <Row>
        {_.map(tiles, (tile,index) =>
          <Tile key = {index} index={index} content={tile} availables={this.state.availables}
            current={this.state.current}
            opaque={this.state.opaque}
            clickTile={this.clickTile.bind(this)}
            onEnterChange={this.onEnterChange.bind(this)}
            onLeaveChange={this.onLeaveChange.bind(this)}/>
        )}
      </Row>
      </div>
    )
  }

  clickTile(index) {
    if (window.ai) {
      this.clickInAi(index);
      return;
    }
    if (!this.validClick(index)) return;
    this.channel.push("click", {index: index, state: this.state})
        .receive("ok", this.gotView.bind(this))

  }

  clickInAi(index) {
    if (!this.validClick(index)) return;
    this.channel.push("aiplay", {index: index, state: this.state})
        .receive("ok", this.gotView.bind(this))
  }

  //check if the tile can be clicked
  validClick(index) {
    if (this.state.player2 == "" || this.state.player1 == "") {
      alert("You need to wait another player")
      return false;
    }
    let curr = this.state.current;
    let curr_name = (curr==1)?this.state.player1:this.state.player2;
    let player = play_cfg.user;
    if (curr_name != player) return false;
    if (this.state.tiles[index] != 0) return false;
    let x = Math.floor(index / 8)
    let y = index % 8
    let flag = false;
    this.state.availables.forEach((a) => {
      if (a[0] == x && a[1] == y) flag = true;
    })
    return flag;
  }



  onEnterChange(index) {
    this.setState({opaque: index});
  }
  onLeaveChange(index) {
    this.setState({opaque: -1});
  }




  pickWhite() {
    if (this.state.player2 != "" && this.state.player2 != play_cfg.user) {
        alert("White has been picked by another user!")
        return;
    }
    let newState = this.state
    newState['player2'] = play_cfg.user
    if (play_cfg.user == this.state.player1) {
      newState['player1'] = ""
    }
    this.channel.push("chess", {"state": newState})
      .receive("ok", (resp) => {})
  }

  pickBlack() {
    if (this.state.player1 != "" && this.state.player1 != play_cfg.user) {
        alert("Black has been picked by another user!")
        return;
    }
    let newState = this.state
    newState['player1'] = play_cfg.user
    if (play_cfg.user == this.state.player2) {
      newState['player2'] = ""
    }

    this.channel.push("chess", {"state": newState})
      .receive("ok", (resp) => {})
  }
  observe() {
    if (this.state.player1 == play_cfg.user) {
      let newState = this.state
      newState['player1'] = ""
      this.channel.push("chess", {"state": newState})
        .receive("ok", (resp) => {})
    } else if (this.state.player2 == play_cfg.user) {
      let newState = this.state
      newState['player2'] = ""
      this.channel.push("chess", {"state": newState})
        .receive("ok", (resp) => {})
    } else {
      return;
    }
  }
}
