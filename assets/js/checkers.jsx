import React from 'react';
import ReactDOM from 'react-dom';
import classnames from 'classnames';

export default function game_init(root,channel) {
  ReactDOM.render(<Checkers channel={channel} />, root);
}

class Checkers extends React.Component {

  constructor(props) {
    super(props);
    this.channel = props.channel;
    this.state = {
       pawns: [],
       moves: {},
       player1: null,
       player2: null,
       spectator: false,
   };
   this.createBoard = this.createBoard.bind(this);
   this.channel.join()
        .receive("ok", this.renderView.bind(this))
        .receive("error",resp => {console.log("unable to join",resp)});
        this.channel.on("assignPlayer", payload => {this.setState(payload.game)})
        this.channel.on("movepawn", payload => {this.setState(payload.game)})

 }

 render(view){
   this.setState(view.game);
 }

renderView(view){
   this.setState(view.game);
 }

  createBoard()
  {
    let pieces = [];
    for(let i=0;i<64;i++)
    {
      let oneSquare = <Square id={i}
                              key={i}
                              pawns={this.state.pawns}
                              prevclick={this.state.previously_clicked}
                              player={this.state.previous_player}
                              pawnClicked={this.pawnClicked.bind(this)}
                              dict = {this.state.moves}
      movepawn={this.movepawn.bind(this)}/>;
      pieces.push(oneSquare);
    }
    return pieces;
  }


  pawnToRemove(piece, value)
  {
    let l = this.state.pawns;
    for(let k =0;k<12;k++){
      if(l[piece][k].position == value)
      {
        return l[piece][k]
      }
    }
  }

  movepawn(id,pawn_id,color)
  {
  console.log("This is Move Pawn")
  console.log(window.userName)
  console.log(this.state)
  if((this.state.player1 == window.userName && this.state.nextChance == "red") ||
     (this.state.player2 == window.userName && this.state.nextChance == "black")){
  this.channel.push("movepawn", {id: id, pawn_id: pawn_id, color: color})
                .receive("ok", this.renderView.bind(this));
    }
  }

  pawnClicked(id,pawn_id,color,player)
  {
    //if((this.state.player1 == window.userName && this.state.nextChance == "red") ||
    //  (this.state.player2 == window.userName && this.state.nextChance == "black")){
    //      this.channel.push("movepawn", {id: id, pawn_id: pawn_id, color: color})
    //                  .receive("ok", this.renderView.bind(this))
    //}
    console.log(" in pawnClicked")
    console.log(id);
    console.log(color);
    console.log(player);
    var valid_pos1;
    var valid_pos2;
    this.setState({previously_clicked:pawn_id})
    this.setState({previous_player:color})
    console.log("setting the dict-------------------------------------")
    console.log(this.state.player1 == window.userName)
    console.log(this.state.player1)
    console.log(window.userName)
    console.log(this.state.nextChance == "red")
    console.log(color == "red")
    console.log(this.state.player2 == window.userName)
    console.log(this.state.nextChance == "black")
    let temp = this.state.moves
    if((this.state.player1 == window.userName && this.state.nextChance == "red" && color == "red") ||
       (this.state.player2 == window.userName && this.state.nextChance == "black"
        && color == "black")){
          this.channel.push("getNextPos", {id: pawn_id, color: color})
              .receive("ok", this.renderView.bind(this));
    }
 }

 setPlayer(){
 this.channel.push("assignPlayer", {id: window.userName})
             .receive("ok", this.renderView.bind(this));
  }

  render()
  {
    if (this.state.pawns.length != 0){
      return(
      <div>
      <button className="primary-btn" onClick={this.setPlayer.bind(this)}>
      Join the game
      </button>
       <div id="layout">
          {this.createBoard()}
      </div>
      </div>
        );
      }
    else{
      return null;
    }
  }
}

function Square(props) {

  const {id, pawns}= props;
  let found = 'none'
  let p_id = 100
  var color ='';
  var highlight_Square = false;
  var normal_Square = true;
  if((parseInt(id / 8))%2==0)
  {
    if(id % 2 == 0)
    {
      color = "#ffffff";
    }
    else
    {
      color = "#000000";
    }
  }
  else
  {
    if(id % 2 == 0)
    {
      color = "#000000";
    }
    else
    {
      color = "#ffffff";
    }
  }
  var clickable = false;
  for(let i=0;i<12;i++)
  {
        if(pawns.red[i].position === id) {
            found = 'red'
            p_id  = pawns.red[i].id
        }
        else if (pawns.black[i].position === id){
            found = 'black'
            p_id = pawns.black[i].id
        }
  }
  if(props.dict[id] !== undefined){
          clickable = true;
          highlight_Square = true;
          normal_Square = false;
  }
  var className = classnames(
               'empty':true,
              {'red piece king': (found === 'red') && (pawns.red[p_id].king) === true},
              {'black piece king': (found === 'black') && (pawns.black[p_id].king) === true},
              {'red piece': (found === 'red') && (pawns.red[p_id].king === false)},
              {'black piece': (found === 'black') && (pawns.black[p_id].king === false)},
              );
  var hightlightclass = classnames(
          {'square': normal_Square},
          {'square_highlight': highlight_Square}
  );
  return (
          <div className= {hightlightclass} style={{backgroundColor: color}}
            onClick={clickable ? () => props.movepawn(id, props.prevclick, props.player) : null}>
          <div className ={className} onClick={() => props.pawnClicked(id, p_id, found, props.player)}/>
          </div>
  );
}
