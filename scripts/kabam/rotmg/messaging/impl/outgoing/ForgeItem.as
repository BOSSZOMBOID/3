package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.SlotObjectData;
   
   public class ForgeItem extends OutgoingMessage
   {
       
      
      public var sor_:SlotObjectData;
      
      public var shard_:SlotObjectData;
      
      public function ForgeItem(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         this.sor_.writeToOutput(param1);
         this.shard_.writeToOutput(param1);
      }
      
      override public function toString() : String
      {
         return formatToString("FORGEITEM","sor_","shard_");
      }
   }
}
