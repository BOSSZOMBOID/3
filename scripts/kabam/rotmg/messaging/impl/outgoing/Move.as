package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.MoveRecord;
   import kabam.rotmg.messaging.impl.data.WorldPosData;
   
   public class Move extends OutgoingMessage
   {
       
      
      public var objectId_:int;
      
      public var tickId_:int;
      
      public var time_:int;
      
      public var options:int;
      
      public var newPosition_:WorldPosData;
      
      public var records_:Vector.<MoveRecord>;
      
      public function Move(param1:uint, param2:Function)
      {
         this.newPosition_ = new WorldPosData();
         this.records_ = new Vector.<MoveRecord>();
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         var _loc2_:int = 0;
         param1.writeInt(this.objectId_);
         param1.writeInt(this.tickId_);
         param1.writeInt(this.time_);
         param1.writeInt(this.options);
         this.newPosition_.writeToOutput(param1);
         param1.writeShort(this.records_.length);
         while(_loc2_ < this.records_.length)
         {
            this.records_[_loc2_].writeToOutput(param1);
            _loc2_++;
         }
      }
      
      override public function toString() : String
      {
         return formatToString("MOVE","objectId_","tickId_","time_","newPosition_","records_");
      }
   }
}
