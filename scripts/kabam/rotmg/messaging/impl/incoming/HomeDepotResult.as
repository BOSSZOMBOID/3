package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class HomeDepotResult extends IncomingMessage
   {
       
      
      public var type_:int;
      
      public function HomeDepotResult(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.type_ = param1.readByte();
      }
      
      override public function toString() : String
      {
         return formatToString("HOMEDEPOTRESULT");
      }
   }
}
