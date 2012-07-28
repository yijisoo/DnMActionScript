// Assumptions:  Data must either be a text or a number (Future: Nominal, ordinal, interval)
//               The location of data type information in the data schema is fixed and known
// Problems:  DataStatistics object does not contain correct information for nominal and ordinal data
//            This affects the color coding and the size encoding and magnet controls (min, max, range are calculated there)


package DustAndMagnet
{
	import DustAndMagnet.MagnetClasses.*;
	
	import flare.data.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.FileFilter;
	
	import mx.containers.*;
	import mx.core.UIComponent;
	
	public class VisualizationComponent extends Canvas implements IEventDispatcher
	{
		public static const VISUALIZATION_INITIALIZED:String = "visualizationInitialized";
		
		// Reference to Data Manager instance.
		private var dataManager:DataManager;
		
		// Object containing arrays of attribute column statistics.  Arrays are dynamically added.
		// Statistics included:  min, max, range
		private var dataStatistics:Object;
		
		private var magnetList:Array;
		private var particleList:Array;
		private var labelList:Array;
		
		private var magnetLayer:UIComponent;
		public var dustLayer:UIComponent;

		public var colorCoder:ColorCoder;
		public var sizeCoder:SizeCoder;
		public var filterManager:FilterManager;

		// Matrix of distances between particles.  Lower-triangular matrix.
		private var distMatrix:Array;
		
		// Variables used for panning and zooming calculations.
		private var currentPoint:Point;
		private var newPoint:Point;

		private static const particleMovementSpeed:Number = 2.5;
		
		public function VisualizationComponent()
		{
			super();
			
			horizontalScrollPolicy = "off";
			verticalScrollPolicy = "off";
			
			magnetList = new Array();
			particleList = new Array();
			labelList = new Array();
			
			magnetLayer = new UIComponent();
			magnetLayer.width = 5000;
			magnetLayer.height = 5000;
			dustLayer = new UIComponent();
			dustLayer.width = 5000;
			dustLayer.height = 5000;
			addChild(magnetLayer);
			addChild(dustLayer);
			
			// Listner for panning.
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
			
			// Listner for zooming.
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelListener);
		}
		
		public function setData(dataManager:DataManager):void
		{			
			this.dataManager = dataManager;
			
			colorCoder = new ColorCoder(this, dataManager);
			sizeCoder = new SizeCoder(this, dataManager);
			filterManager = new FilterManager(this, dataManager);
			
			var data:Array = this.dataManager.getData();
			var dataSchema:Array = this.dataManager.getDataSchema();
			
			summarizeData(data);
			
			// Create dust particles at the center of the screen and initialize distMatrix.
			var i:int;
			for (i = 0; i < data.length; i++)
			{
				particleList.push(new Particle(i, dataManager));
				dustLayer.addChild(particleList[i]);
			}
			centerDust();		
			
			// Create a list of all possible magnets.
			for (i = 0; i < dataSchema.length; i++)
			{
				// Determine the type of magnet to create based on the datatype
				if (dataSchema[i][8] == DataManager.INTERVAL)
				{
					magnetList.push(new IntervalMagnet(i, dataManager, dataStatistics));
				}
				else if (dataSchema[i][8] == DataManager.NOMINAL)
				{
					magnetList.push(new NominalMagnet(i, dataManager, dataStatistics));
				}
				else if (dataSchema[i][8] == DataManager.ORDINAL)
				{
					magnetList.push(new OrdinalMagnet(i, dataManager, dataStatistics));
				}
				else
				{
					throw(new Error("Unknown datatype for magnet creation"));
				}
			}
			
			dispatchEvent(new Event(VisualizationComponent.VISUALIZATION_INITIALIZED, true));
		}

		private function summarizeData(data:Array):void
		{
			dataStatistics = new Object();
			dataStatistics.min = new Array();
			dataStatistics.max = new Array();
			dataStatistics.range = new Array();
			
			for (var i:int = 0; i < data[0].length; i++)
			{
				dataStatistics.min.push(data[0][i]);
				dataStatistics.max.push(data[0][i]);
				for (var j:int = 1; j < data.length; j++)
				{
					if (data[j][i] < dataStatistics.min[i])
					{
						dataStatistics.min[i] = data[j][i];
					}
					if (data[j][i] > dataStatistics.max[i])
					{
						dataStatistics.max[i] = data[j][i];
					}
				}
				dataStatistics.range.push(dataStatistics.max[i]-dataStatistics.min[i]);
			}
		}
		
		public function getDataManager():DataManager
		{
			return dataManager;
		}
		
		public function getDataStatistics():Object
		{
			return dataStatistics;
		}
		
		public function getParticleList():Array
		{
			return particleList;
		}

		public function getMagnetList():Array
		{
			return magnetList;
		}
		
		public function addMagnet(attributeKey:int):void
		{
			if (attributeKey > 0 && magnetList[attributeKey].isActive == false)
			{
				var point:Point = this.localToGlobal(new Point(this.width/4, this.height/4));
				
				magnetList[attributeKey].isActive = true;
				magnetList[attributeKey].setPosition(magnetLayer.globalToLocal(point));
				magnetList[attributeKey].addEventListener(Magnet.MAGNET_MOVED, magnetMovedListener);
				magnetLayer.addChild(magnetList[attributeKey]);
			}
		}
		
		public function deleteMagnet(attributeKey:int):void
		{
			if (attributeKey > 0 && magnetList[attributeKey].isActive == true)
			{
				magnetList[attributeKey].isActive = false;
				magnetList[attributeKey].removeEventListener(Magnet.MAGNET_MOVED, magnetMovedListener);
				magnetLayer.removeChild(magnetList[attributeKey]);
			}
		}
		
		public function attractDust():void
		{
			var attraction:Point;
			var netAttraction:Point;
			var newPosition:Point;
			var isCollision:Boolean;
			
			for (var i:int = 0; i < particleList.length; i++)
			{
				netAttraction = new Point();
				newPosition = new Point();
				
				for (var j:int = 0; j < magnetList.length; j++)
				{
					if (j == dataManager.getPrimaryKeyIndex()) continue;
					if (magnetList[j].isActive == true)
					{
						attraction = magnetList[j].getAttraction(particleList[i]);
						netAttraction.x += attraction.x;
						netAttraction.y += attraction.y;
					}
				}
				
				if (netAttraction.x != Infinity && netAttraction.x != -Infinity &&
					netAttraction.y != Infinity && netAttraction.y != -Infinity &&
					isNaN(netAttraction.x) == false && isNaN(netAttraction.y) == false)
				{
					newPosition.x = particleList[i].getPosition().x + VisualizationComponent.particleMovementSpeed * netAttraction.x;
					newPosition.y = particleList[i].getPosition().y + VisualizationComponent.particleMovementSpeed * netAttraction.y;
					particleList[i].setPosition(newPosition);
				}
			}
		}
		
		public function centerDust():void
		{
			var center:Point = this.localToGlobal(new Point(this.width/2, this.height/2));
			for (var i:int = 0; i < particleList.length; i++)
			{
				particleList[i].setPosition(dustLayer.globalToLocal(center));
			}
		}
		
		public function shakeDust():void
		{
			for (var i:int = 0; i < particleList.length; i++)
			{
				updateDistMatrix();
				
				// Create a movement speed that causes large particles to move slower in order to keep
				// larger particles at the center of clusters.
				var movementSpeed:Number = 4 * VisualizationComponent.particleMovementSpeed * Math.pow(particleList[i].getRadius(), -0.5);
				
				var neighbors:Array = getNeighborParticleIndexes(particleList[i]);
				
				if (neighbors.length > 0)
				{
					var direction:Point = new Point(0, 0);
					for (var j:int = 0; j < neighbors.length; j++)
					{
						direction.x += particleList[i].getPosition().x - particleList[neighbors[j]].getPosition().x;
						direction.y += particleList[i].getPosition().y - particleList[neighbors[j]].getPosition().y;
					}
					
					var newPosition:Point;
					if ((direction.x == 0) && (direction.y == 0))
					{
						// Spread neighbor particles in a circular arc around current particle.
						// Random() is used to make the action appear natural.
						for (j = 0; j < neighbors.length; j++)
						{
							newPosition = new Point();
							newPosition.x = particleList[i].getPosition().x + movementSpeed *
								Math.random() * Math.cos((j+1) / (neighbors.length+1) * 2 * Math.PI);
							newPosition.y = particleList[i].getPosition().y + movementSpeed *
								Math.random() * Math.sin((j+1) / (neighbors.length+1) * 2 * Math.PI);	
									
							particleList[neighbors[j]].setPosition(newPosition);
						}
						
						newPosition = new Point();
						newPosition.x = particleList[i].getPosition().x + movementSpeed * Math.random();
						newPosition.y = particleList[i].getPosition().y;	
									
						particleList[i].setPosition(newPosition);
					}
					else
					{
						direction.x /= Point.distance(direction, new Point(0,0));
						direction.y /= Point.distance(direction, new Point(0,0));
					
						newPosition = new Point();	
						newPosition.x = particleList[i].getPosition().x + movementSpeed * direction.x;
						newPosition.y = particleList[i].getPosition().y + movementSpeed * direction.y;	
									
						particleList[i].setPosition(newPosition);
					}
				}
			}
		}
		
		private function getNeighborParticleIndexes(particle:Particle):Array
		{
			var neighbors:Array = new Array();
			var dist:Number;
			
			for (var i:int = 0; i < particleList.length; i++)
			{
				if (i == particle.getTupleKey()) continue;
				
				if (i < particle.getTupleKey())
				{
					dist = distMatrix[particle.getTupleKey()][i];
				}
				else
				{
					dist = distMatrix[i][particle.getTupleKey()];	
				}
				
				if (dist < particle.getRadius() + particleList[i].getRadius())
				{
					neighbors.push(i);
				}
			}
			
			return neighbors;
		}
		
		public function updateDistMatrix(particle:Particle = null):void
		{
			var i:int;
			
			if (distMatrix == null || particle == null)
			{
				distMatrix = new Array();
				
				for (i = 0; i < particleList.length; i++)
				{
					distMatrix.push(new Array());
					distMatrix[i].length = i + 1;
					
					if (particleList[i].isVisible == false) continue;
					for (var j:int = 0; j < distMatrix[i].length; j++)
					{
						if (particleList[j].isVisible == false) continue;
						distMatrix[i][j] = Point.distance(particleList[i].getPosition(), particleList[j].getPosition());
					}
				}
			}
			else
			{
			// This will make the shake dust feature more efficient.  However, it is not working properly.
				for (i = 0; i < particleList.length; i++)
				{
					if (i == particle.getTupleKey()) continue;
					if (i < particle.getTupleKey())
					{
						distMatrix[particleList[i].getTupleKey()][i] = Point.distance(particle.getPosition(), particleList[i].getPosition());
					}
					else
					{
						distMatrix[i][particleList[i].getTupleKey()] = Point.distance(particle.getPosition(), particleList[i].getPosition());
					}
				}
			}
		}
		
		
		private function magnetMovedListener(e:Event):void
		{
			attractDust();
		}
		
		// Panning listeners
		private function mouseDownListener(e:MouseEvent):void
		{
			if (e.target is Canvas)
			{	
				currentPoint = this.globalToLocal(new Point(e.stageX, e.stageY));
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveListener);
				stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpListener);
			}
		}
		
		private function mouseMoveListener(e:MouseEvent):void
		{
			newPoint = this.globalToLocal(new Point(e.stageX, e.stageY));

			dustLayer.x += newPoint.x - currentPoint.x;
			dustLayer.y += newPoint.y - currentPoint.y;
			
			magnetLayer.x += newPoint.x - currentPoint.x;
			magnetLayer.y += newPoint.y - currentPoint.y;
			
			currentPoint = newPoint;
			
			e.updateAfterEvent();
		}
		
		private function mouseUpListener(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveListener);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpListener);	
		}
		
		private function mouseWheelListener(e:MouseEvent):void
		{
			var transformMatrix:Matrix = new Matrix();
			
			if (e.delta < 0 )//&& scale - 0.1 >= 0.5)
			{
				transformMatrix = dustLayer.transform.matrix;
				transformMatrix.translate(-e.stageX, -e.stageY);
				transformMatrix.scale(0.9, 0.9);
				transformMatrix.translate(e.stageX, e.stageY);
				dustLayer.transform.matrix = transformMatrix;
				
				transformMatrix = magnetLayer.transform.matrix;
				transformMatrix.translate(-e.stageX, -e.stageY);
				transformMatrix.scale(0.9, 0.9);
				transformMatrix.translate(e.stageX, e.stageY);
				magnetLayer.transform.matrix = transformMatrix;
			}
			else if (e.delta > 0)
			{
				transformMatrix = dustLayer.transform.matrix;
				transformMatrix.translate(-e.stageX, -e.stageY);
				transformMatrix.scale(1.1, 1.1);
				transformMatrix.translate(e.stageX, e.stageY);
				dustLayer.transform.matrix = transformMatrix;
				
				transformMatrix = magnetLayer.transform.matrix;
				transformMatrix.translate(-e.stageX, -e.stageY);
				transformMatrix.scale(1.1, 1.1);
				transformMatrix.translate(e.stageX, e.stageY);
				magnetLayer.transform.matrix = transformMatrix;
			}
		}
	}
}