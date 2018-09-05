import React, { Component } from 'react';
import { Col } from 'reactstrap';
import _ from 'underscore';
import $ from 'jquery'

// import Black from 'black.jpg';
// import White from 'white.jpg';


export default function(props) {


  let blackUrl = '../images/black.png';
  let whiteUrl = '../images/white.png';
  let black2 = '../images/black2.jpg'
  let white2 = '../images/white2.jpg'


  var blackTileStyle = {
    backgroundImage: 'url('+blackUrl+')'
  }

  var whiteTileStyle = {
    backgroundImage: 'url('+whiteUrl+')'
  }

  var blackOpaque = {
    backgroundImage: 'url('+black2+')'
  }

  var whiteOpaque = {
    backgroundImage: 'url('+white2+')'
  }

  // const onHoverChange = () => {
  //   $()
  // }

  const showContent = (content) => {
    if (content == 0) {
      let x = Math.floor(props.index / 8)
      let y = props.index % 8
      let flag = false;
      props.availables.forEach((a) => {
        if (a[0] == x && a[1] == y) flag = true;
      })
      if (flag && props.current == 1 && props.opaque == props.index) return blackOpaque;
      else if (flag && props.current == 2 && props.opaque == props.index) return whiteOpaque;
      else return;

    } else if (content == 1) {
      return blackTileStyle;
    } else {
      return whiteTileStyle;
    }
  };


  return (
    <div className="parent">
      <div className="tile" onClick={() => props.clickTile(props.index)}
         onMouseEnter={() => props.onEnterChange(props.index)}
          onMouseLeave={() => props.onLeaveChange(props.index)}
           style={showContent(props.content)}>
      </div>
    </div>

  )
}
