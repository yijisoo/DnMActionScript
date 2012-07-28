package DustAndMagnet
{
	import flash.events.*;
	
	import mx.containers.*;
	import mx.controls.*;
	import mx.controls.dataGridClasses.DataGridColumn;

	public class DetailPanel extends Panel
	{
		private var dataManager:DataManager;
		private var visualization:VisualizationComponent;
		
		private var dataGrid:DataGrid;
		private var dataProvider:Array = new Array();
		private var dataProviderHashMap:Array = new Array();
		
		public function DetailPanel()
		{
			super();
			
			title = "Detail View";
			
			dataGrid = new DataGrid();
			addChild(dataGrid);
			dataGrid.percentHeight = 100;
		}
		
		public function setData(dataManager:DataManager):void
		{			
			this.dataManager = dataManager;
			
			var columns:Array = new Array();
			for (var i:int = 0; i < this.dataManager.getDataSchema().length; i++)
			{
				columns.push(new DataGridColumn());
				columns[columns.length - 1].headerText = dataManager.getDataSchema()[i][0];
				columns[columns.length - 1].dataField = i;
			}
			dataGrid.columns = columns;
		}

// TODO:  Change listener to Particle_Clicked event
		public function setVisualization(visualization:VisualizationComponent):void
		{
			this.visualization = visualization;
			
			var particleList:Array = visualization.getParticleList();
			for (var i:int = 0; i < particleList.length; i++)
			{
				particleList[i].addEventListener(MouseEvent.CLICK, mouseClickedListener);
			}
		}
		
		private function update():void
		{
			
		}
				
		private function mouseClickedListener(e:MouseEvent):void
		{
			if (e.currentTarget.getLabelIsVisible() == true)
			{
				dataProvider.push(dataManager.getData()[e.currentTarget.getTupleKey()]);
				dataProviderHashMap.push(e.currentTarget.getTupleKey());
				dataGrid.dataProvider = dataProvider;
			}
			else
			{
				var index:int;
				for (var i:int = 0; i < dataProviderHashMap.length; i++)
				{
					if (e.currentTarget.getTupleKey() == dataProviderHashMap[i])
					{
						index = i;
						break;
					}
				}
				dataProvider.splice(i, 1);
				dataProviderHashMap.splice(i, 1);
				dataGrid.dataProvider = dataProvider;
			}	
		}
	}
}