package DustAndMagnet.MagnetClasses
{
	import DustAndMagnet.*;
	
	import flare.data.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	//  Abstract Class
	public class Magnet extends UIComponent
	{	
		public static const MAGNET_MOVED:String = "magnetMoved";
		public static const MAGNET_CLICKED:String = "magnetClicked";
		
		public static const minMagnitude:int = 0;
		public static const maxMagnitude:int = 100;
		private static const color:int = 0x777766;
		public static const standardSideLength:Number = 40;
		
		protected var magnet_id:String;
		protected var label:SpriteLabel;
		protected var attributeKey:int;
		protected var magnitude:int;
		public var repulsionThreshold:Number;
		protected var shape:Shape;
		protected var sideLength:Number;
		protected var handle:Point;
		public var isActive:Boolean;
		
		protected var dataManager:DataManager;
		protected var dataStatistics:Object;
		
		public function Magnet(attributeKey:int, dataManager:DataManager, dataStatistics:Object)
		{
			super();
			
			this.dataManager = dataManager;
			this.dataStatistics = dataStatistics;
			
			this.magnet_id	= dataManager.getDataSchema()[attributeKey][1];   // 1 is the location of the column title
			
			this.attributeKey = attributeKey;
			x = Magnet.standardSideLength/2;
			y = Magnet.standardSideLength/2;
			magnitude = maxMagnitude;
			repulsionThreshold = dataStatistics.min[attributeKey];
			
			isActive = false;
			
			sideLength = Magnet.standardSideLength;
			shape = new Shape();
			shape.graphics.beginFill(color, 1);
			shape.graphics.drawRect(-sideLength/2, -sideLength/2, sideLength, sideLength);
			addChild(shape);
			label = new SpriteLabel(magnet_id, 0x000000);
			label.isVisible = true;
			addChild(label);
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
			addEventListener(MouseEvent.MOUSE_DOWN, magnetClickListener);
		}
		
		public function getID():String
		{
			return magnet_id;
		}
		
		public function getAttributeKey():int
		{
			return attributeKey;
		}
		
		public function getPosition():Point
		{
			return new Point(x, y);
		}
		
		public function setPosition(position:Point):void
		{
			x = position.x;
			y = position.y;
		}
		
		public function getMagnitude():int
		{
			return magnitude;	
		}
		
		public function setMagnitude(magnitude:int):void
		{
			this.magnitude = magnitude;
			
			var newSideLength:Number = (magnitude/200 + 0.5) * Magnet.standardSideLength
			
			shape.graphics.clear();
			shape.graphics.beginFill(color, 1);
			shape.graphics.drawRect(-newSideLength/2, -newSideLength/2, newSideLength, newSideLength);
			addChild(shape);
			addChild(label);
			
			if (magnitude == 0)
			{
				alpha = 0.5;
			}
			else
			{
				alpha = 1;
			}
		}
	
		// Abstract Methods
		public function getAttraction(particle:Particle):Point
		{
			return new Point();
		}
		
		// Listeners
		private function magnetClickListener(e:MouseEvent):void
		{
			dispatchEvent(new Event(Magnet.MAGNET_CLICKED, true));
		}
	
		// These listeners listen for a click-and-drag
		private function mouseDownListener(e:MouseEvent):void
		{
			parent.setChildIndex(this, parent.numChildren - 1);
			
			handle = this.globalToLocal(new Point(e.stageX, e.stageY));
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
		}
		
		private function mouseMoveListener(e:MouseEvent):void
		{
			var pointInParent:Point = parent.globalToLocal(new Point(e.stageX, e.stageY));
			
			x = pointInParent.x - handle.x;
			y = pointInParent.y - handle.y;
			
			dispatchEvent(new Event(Magnet.MAGNET_MOVED, true));
			e.updateAfterEvent();
		}
		
		private function mouseUpListener(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpListener);	
		}
		

	}
}