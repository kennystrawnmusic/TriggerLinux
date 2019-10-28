/* === This file is part of Calamares - <http://github.com/calamares> ===
 *
 *   Copyright 2015, Teo Mrnjavac <teo@kde.org>
 *
 *   Calamares is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Calamares is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Calamares. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
  id: presentation

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: presentation.goToNextSlide()
  }
   
  BackButton {
    width: 50
    height: 50
    source: "back.png"
  }
  
  ForwardButton {
   width: 50
   height: 50
   source: "forward.png"
  }
  
  Slide {
    
    Image {
      id: background1
      source: "1.png"
      width: 800; height: 440
      fillMode: Image.PreserveAspectFit
      anchors.centerIn: parent
    }
  }
  Slide {
    
    Image {
      id: background2
      source: "2.png"
      width: 800; height: 440
      fillMode: Image.PreserveAspectFit
      anchors.centerIn: parent
    }
  }
  Slide {
    
    Image {
      id: background3
      source: "3.png"
      width: 800; height: 440
      fillMode: Image.PreserveAspectFit
      anchors.centerIn: parent
    }
  }
  Slide {
    
    Image {
      id: background4
      source: "4.png"
      width: 800; height: 440
      fillMode: Image.PreserveAspectFit
      anchors.centerIn: parent
    }
  }
}
