package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class AllyShoot extends IncomingMessage
   {
       
      
      public var bulletId_:uint;
      
      public var ownerId_:int;
      
      public var containerType_:int;
      
      public var angle_:Number;
      
      public function AllyShoot(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.bulletId_ = param1.readInt();
         this.ownerId_ = param1.readInt();
         this.containerType_ = param1.readShort();
         this.angle_ = param1.readFloat();
      }
      
      override public function toString() : String
      {
         return formatToString("ALLYSHOOT","bulletId_","ownerId_","containerType_","angle_");
      }
   }
}
