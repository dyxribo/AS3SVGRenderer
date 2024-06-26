﻿package com.lorentz.SVG.display {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;

import com.lorentz.SVG.data.text.SVGDrawnText;
import com.lorentz.SVG.display.base.SVGTextContainer;
import com.lorentz.SVG.utils.DisplayUtils;
import com.lorentz.SVG.utils.SVGUtil;

public class SVGTSpan extends SVGTextContainer {
		private var _svgDx:String;
		public function get svgDx():String {
			return _svgDx;
		}
		public function set svgDx(value:String):void {
			if(_svgDx != value){
				_svgDx = value;
				invalidateRender();
			}
		}
		
		private var _svgDy:String;
		public function get svgDy():String {
			return _svgDy;
		}
		public function set svgDy(value:String):void {
			if(_svgDy != value){
				_svgDy = value;
				invalidateRender();
			}
		}

		public function SVGTSpan(){
			super("tspan");
		}
		
		private var _start:Number = 0;
		private var _end:Number = 0;
				
		override protected function render():void {
			super.render();
			
			while(content.numChildren > 0)
				content.removeChildAt(0);
			
			if(this.numTextElements == 0)
				return;
			
			var direction:String = getDirectionFromStyles() || "lr";
			var textDirection:String = direction;
						
			if(svgX)
				textOwner.currentX = getViewPortUserUnit(svgX, SVGUtil.WIDTH);
			if(svgY)
				textOwner.currentY = getViewPortUserUnit(svgY, SVGUtil.HEIGHT);
			
			_start = textOwner.currentX;
			_renderObjects = new Vector.<DisplayObject>();
			
			if(svgDx)
				textOwner.currentX += getViewPortUserUnit(svgDx, SVGUtil.WIDTH);
			if(svgDy)
				textOwner.currentY += getViewPortUserUnit(svgDy, SVGUtil.HEIGHT);
						
			var fillTextsSprite:Sprite;
			
			if(hasComplexFill)
			{
				fillTextsSprite = new Sprite();
				content.addChild(fillTextsSprite);
			} else {
				fillTextsSprite = content;				
			}
			
			for(var i:int = 0; i < numTextElements; i++){
				var textElement:Object = getTextElementAt(i);
				
				if(textElement is String){
					var drawnText:SVGDrawnText = createTextSprite( textElement as String, document.textDrawer );
										
					if((drawnText.direction || direction) == "lr"){
						drawnText.displayObject.x = textOwner.currentX - drawnText.startX;
						drawnText.displayObject.y = textOwner.currentY - drawnText.startY - drawnText.baseLineShift;
						textOwner.currentX += drawnText.textWidth;
					} else {
						drawnText.displayObject.x = textOwner.currentX - drawnText.textWidth - drawnText.startX;
						drawnText.displayObject.y = textOwner.currentY - drawnText.startY - drawnText.baseLineShift;
						textOwner.currentX -= drawnText.textWidth;
					}

					if(drawnText.direction)	
						textDirection = drawnText.direction;
					
					fillTextsSprite.addChild(drawnText.displayObject);
					_renderObjects.push(drawnText.displayObject);
				} else if(textElement is SVGTextContainer) {
					var tspan:SVGTextContainer = textElement as SVGTextContainer;
										
					if(tspan.hasOwnFill()){
						textOwner.textContainer.addChild(tspan);
					} else
						fillTextsSprite.addChild(tspan);
					
					tspan.invalidateRender();
					tspan.validate();
					
					_renderObjects.push(tspan);
				}				
			}
			
			_end = textOwner.currentX;
						
			if(svgX)
				doAnchorAlign(textDirection, _start, _end);
						
			if(hasComplexFill && fillTextsSprite.numChildren > 0){
				var bounds:Rectangle = DisplayUtils.safeGetBounds(fillTextsSprite, content);
				bounds.inflate(2, 2);
				var fill:Sprite = new Sprite();
				beginFill(fill.graphics);
				fill.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
				fill.mask = fillTextsSprite;
				fillTextsSprite.cacheAsBitmap = true;
				fill.cacheAsBitmap = true;
				content.addChildAt(fill, 0);
				
				_renderObjects.push(fill);
			}
		}
				
		override public function clone():Object {
			var c:SVGTSpan = super.clone() as SVGTSpan;
			c.svgX = svgX;
			c.svgY = svgY;
			c.svgDx = svgDx;
			c.svgDy = svgDy;
			return c;
		}
	}
}