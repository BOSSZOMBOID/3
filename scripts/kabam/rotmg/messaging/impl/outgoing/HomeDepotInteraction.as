package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class HomeDepotInteraction extends OutgoingMessage
   {
       
      
      public var type_:int;
      
      public var name_:String;
      
      public var stack_:int;
      
      public function HomeDepotInteraction(param1:uint, param2:Function)
      {
         super(param1,param2);
         this.name_ = new String();
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeByte(this.type_);
         param1.writeUTF(this.name_);
         param1.writeInt(this.stack_);
      }
      
      override public function toString() : String
      {
         return formatToString("HOMEDEPOTINTERACTION");
      }
   }
}
