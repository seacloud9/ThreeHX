package three.renderers;

import haxe.ds.Vector;
import three.cameras.Camera;
import three.core.Projector;
import three.core.Object3D;
import three.core.RenderData;
import three.core.Geometry;
import three.lights.Light;
import three.materials.Material;
import three.math.Box2;
import three.math.Box3;
import three.math.Color;
import three.math.Vector2;
import three.math.Vector3;
import three.math.Vector4;
import three.renderers.renderables.Renderable;
import three.renderers.renderables.RenderableFace3;
import three.renderers.renderables.RenderableFace4;
import three.renderers.renderables.RenderableLine;
import three.renderers.renderables.RenderableParticle;
import three.renderers.renderables.RenderableVertex;
import three.scenes.Scene;
import three.textures.Texture;
import three.THREE;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.Lib;
import openfl.display.OpenGLView;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GLUniformLocation;
import openfl.utils.Float32Array;
import openfl.Assets;


class GlRender extends Sprite {

	public var info:Dynamic;
	public var parameters:Dynamic;
	public var RendererParameters:Dynamic;
    public var autoClear:Bool;
    public var autoClearColor:Bool;
    public var autoClearDepth:Bool;
    public var autoClearStencil:Bool;
 	// scene graph
    public var sortObjects:Bool;
    public var autoUpdateObjects:Bool;
    public var autoUpdateScene:Bool;
  	// physically based shading
    public var gammaInput:Bool;
    public var gammaOutput:Bool;
    public var physicallyBasedShading:Bool;
    // shadow map
    public var shadowMapEnabled:Bool;
    public var shadowMapAutoUpdate:Bool;
    public var shadowMapSoft:Bool;
    public var shadowMapCullFrontFaces:Bool;
    public var shadowMapDebug:Bool;
    public var shadowMapCascade:Bool;
    // morphs
    public var maxMorphTargets:Int;
    public var maxMorphNormals:Int;
    // flags
    public var autoScaleCubemaps:Bool;
    private var _width:Int;
    private var _height:Int;
	private var bool _vsync:Bool;
	private var _precision:String;
	private var _alpha:Bool;
	private var _premultipliedAlpha:Bool;;
	private var _antialias:Bool;;
	private var _stencil:Bool;;
	private var _preserveDrawingBuffer:Bool;;
	private var _clearColor:Color;
	private var _clearAlpha:Float;
	private var _maxLights:Int;
	

	public function new (?parameters:Dynamic) {
		super ();
		if (OpenGLView.isSupported) {
			view = new OpenGLView ();
			
			initializeShaders ();
			createBuffers ();
			createTexture ();
			view.render = render;
			addChild (view);
			
		}
		
	}

	private function render (rect:Rectangle):Void {
		
		GL.viewport (Std.int (rect.x), Std.int (rect.y), Std.int (rect.width), Std.int (rect.height));
		
		
		//////////////////




		/*
				if ( camera instanceof THREE.Camera === false ) {

			console.error( 'THREE.WebGLRenderer.render: camera is not an instance of THREE.Camera.' );
			return;

		}

		var i, il,

		webglObject, object,
		renderList,

		lights = scene.__lights,
		fog = scene.fog;

		// reset caching for this frame

		_currentMaterialId = -1;
		_lightsNeedUpdate = true;

		// update scene graph

		if ( scene.autoUpdate === true ) scene.updateMatrixWorld();

		// update camera matrices and frustum

		if ( camera.parent === undefined ) camera.updateMatrixWorld();

		camera.matrixWorldInverse.getInverse( camera.matrixWorld );

		_projScreenMatrix.multiplyMatrices( camera.projectionMatrix, camera.matrixWorldInverse );
		_frustum.setFromMatrix( _projScreenMatrix );

		// update WebGL objects

		if ( this.autoUpdateObjects ) this.initWebGLObjects( scene );

		// custom render plugins (pre pass)

		renderPlugins( this.renderPluginsPre, scene, camera );

		//

		_this.info.render.calls = 0;
		_this.info.render.vertices = 0;
		_this.info.render.faces = 0;
		_this.info.render.points = 0;

		this.setRenderTarget( renderTarget );

		if ( this.autoClear || forceClear ) {

			this.clear( this.autoClearColor, this.autoClearDepth, this.autoClearStencil );

		}

		// set matrices for regular objects (frustum culled)

		renderList = scene.__webglObjects;

		for ( i = 0, il = renderList.length; i < il; i ++ ) {

			webglObject = renderList[ i ];
			object = webglObject.object;

			webglObject.id = i;
			webglObject.render = false;

			if ( object.visible ) {

				if ( ! ( object instanceof THREE.Mesh || object instanceof THREE.ParticleSystem ) || ! ( object.frustumCulled ) || _frustum.intersectsObject( object ) ) {

					setupMatrices( object, camera );

					unrollBufferMaterial( webglObject );

					webglObject.render = true;

					if ( this.sortObjects === true ) {

						if ( object.renderDepth !== null ) {

							webglObject.z = object.renderDepth;

						} else {

							_vector3.getPositionFromMatrix( object.matrixWorld );
							_vector3.applyProjection( _projScreenMatrix );

							webglObject.z = _vector3.z;

						}

					}

				}

			}

		}

		if ( this.sortObjects ) {

			renderList.sort( painterSortStable );

		}

		// set matrices for immediate objects

		renderList = scene.__webglObjectsImmediate;

		for ( i = 0, il = renderList.length; i < il; i ++ ) {

			webglObject = renderList[ i ];
			object = webglObject.object;

			if ( object.visible ) {

				setupMatrices( object, camera );

				unrollImmediateBufferMaterial( webglObject );

			}

		}

		if ( scene.overrideMaterial ) {

			var material = scene.overrideMaterial;

			this.setBlending( material.blending, material.blendEquation, material.blendSrc, material.blendDst );
			this.setDepthTest( material.depthTest );
			this.setDepthWrite( material.depthWrite );
			setPolygonOffset( material.polygonOffset, material.polygonOffsetFactor, material.polygonOffsetUnits );

			renderObjects( scene.__webglObjects, false, "", camera, lights, fog, true, material );
			renderObjectsImmediate( scene.__webglObjectsImmediate, "", camera, lights, fog, false, material );

		} else {

			var material = null;

			// opaque pass (front-to-back order)

			this.setBlending( THREE.NoBlending );

			renderObjects( scene.__webglObjects, true, "opaque", camera, lights, fog, false, material );
			renderObjectsImmediate( scene.__webglObjectsImmediate, "opaque", camera, lights, fog, false, material );

			// transparent pass (back-to-front order)

			renderObjects( scene.__webglObjects, false, "transparent", camera, lights, fog, true, material );
			renderObjectsImmediate( scene.__webglObjectsImmediate, "transparent", camera, lights, fog, true, material );

		}

		// custom render plugins (post pass)

		renderPlugins( this.renderPluginsPost, scene, camera );


		// Generate mipmap if we're using any kind of mipmap filtering

		if ( renderTarget && renderTarget.generateMipmaps && renderTarget.minFilter !== THREE.NearestFilter && renderTarget.minFilter !== THREE.LinearFilter ) {

			updateRenderTargetMipmap( renderTarget );

		}

		// Ensure depth buffer writing is enabled so it can be cleared on next render

		this.setDepthTest( true );
		this.setDepthWrite( true );

		// _gl.finish();

		*/
	}



	public function setSize(width:Int, height:Int):Void{

	}

	public function setViewport(x:Int = 0,y:Int = 0,width:Int = -1,height:Int = -1):Void{

	}

	public function setScissor(x:Int, y:Int, width:Int, height:Int):Void{

	}

	public function enableScissorTest(enable:Bool):Void{

	}

	public function setClearColor(color:Color, alpha:Float):Void{
		
	}

	public function setClearColorHex(hex:Int, alpha:Float):Void{
		
	}

	public function getClearColor():Color{
		return _clearColor;
	}

	public function getClearAlpha():Float{
		return _clearAlpha;
	}

	public function clear(color:Bool = true, depth:Bool = true, stencil:Bool = true):Void{

	}
	///???
	public function clearTarget(renderTarget:Dynamic, color:Bool = true, depth:Bool = true, stencil:Bool = true):Void{

	}

	public function addPostPlugin():Void{
		
	}

	public function addPrePlugin():Void{
		
	}

	public function updateShadowMap(scene:Scene, camera:Camera):Void{
		
	}

	private function createParticleBuffers(geometry:Geometry):Void{
		
	}

	public function createLineBuffers(geometry:Geometry):Void{
		
	}

	public function createMeshBuffers(geometryGroup:GeometryGroup):Void{
		
	}

	public function onGeometryDispose():Void{
		
	}

	public function onTextureDispose():Void{
		
	}

	public function onRenderTargetDispose():Void{
		
	}

	public function onMaterialDispose():Void{
		
	}

	public function deleteBuffers():Void{
		
	}

	public function deallocateGeometry(geometry:Geometry):Void{
		
	}

	public function deallocateTexture(texture:Texture):Void{
		
	}

	public function deallocateRenderTarget(target:Dynamic):Void{
		
	}

	public function deallocateMaterial(material:Material):Void{
		
	}
	private function initCustomAttributes(geometry:Geometry, object:Object3D):Void{
		
	}
	private function initParticleBuffers(geometry:Geometry, object:Object3D):Void{
		
	}
	private function initLineBuffers(geometry:Geometry, object:Object3D):Void{
		
	}
	private function initRibbonBuffers(geometry:Geometry):Void{
		
	}
	public function initMeshBuffers(geometryGroup:GeometryGroup, object:Mesh):Void{
		
	}
	private function getBufferMaterial(object:Object3D, geometryGroup:GeometryGroup):Material{
		
	}
	private function materialNeedsSmoothNormals(material:Material):Bool{
		
	}
	private function bufferGuessVertexColorType(material:Material):Colors{
		
	}
	private function bufferGuessUVType(material:Material):Bool{
		
	}
	private function initDirectBuffers( geometry:Geometry ):Void{
		
	}
	private function setParticleBuffers(geometry:Geometry, hint:Int, object:Object3D ):Void{
		
	}
	private function setLineBuffers(geometry:Geometry, hint:Int):Void{
		
	}
	private function setRibbonBuffers(geometry:Geometry, hint:Int):Void{
		
	}
	private function setMeshBuffers( geometryGroup:GeometryGroup, object:Object3D, hint:Int, dispose:Bool, material:Material ):Void{
		
	}

	private function setDirectBuffers(geometry:Geometry, hint:Int, dispose:Bool):Void{
		
	}
	
	private function renderBuffer(camera:Camera, lights:Array<Light>,fog:Fog, material:Material, geometry:Geometry, object:Object3D):Void{
		
	}

	private function renderBufferDirect(camera:Camera, lights:Array<Light>, fog:Fog, material:Material, geometry:Geometry, object:Object3D):Void{
		
	}

	private function renderBufferImmediate(object:Object3D, program:Dynamic, material:Material):Void{
		
	}

	private function enableAttribute(attribute:Dynamic):Void{

	}

	private function disableAttributes():Void{

	}

	private function setupMorphTargets(material:Material, geometryGroup:GeometryGroup, object:Object3D):Void{
		
	}

	public function painterSortStable(a:Dynamic, b:Dynamic){
		
	}

	public function numericalSort(a:Int,b:Int){
		
	}

	private function renderPlugins(plugins:Array<Dynamic>, scene:Scene, camera:Camera ):Void{

	}

	private function renderObjects(renderList:Array<Object3D>, reverse:Bool, materialType:Int, camera:Camera, lights:Array<Light>, fog:Fog, useBlending:Bool, ?overrideMaterial:Material):Void{

	}

	private function renderObjectsImmediate(renderList:Array<Object3D>, materialType:Int, camera:Camera, lights:Array<Light>, fog:Fog, useBlending:Bool, ?overrideMaterial:Material):Void{

	}

	private function renderImmediateObject(camera:Camera, lights:Array<Light>, fog:Fog, material:Material, object:Object3D):Void{

	}	

	public function unrollImmediateBufferMaterial(globject:Object3D):Void{

	}

	public function unrollBufferMaterial(globject:Object3D):Void{

	}

	public function sortFacesByMaterial(geometry:Geometry, material:Material):Void{

	}

	private function initWebGLObjects(scene:Scene):Void{

	}

	public function addObject(object:Object3D, scene:Scene):Void{

	}

	public function addBuffer(objlist:Array<Object3D>, buffer:Array<Dynamic>, object:Object3D):Void{

	}

	public function addBufferImmediate(objlist:Array<Object3D>, object:Object3D):Void{

	}

	public function updateObject( object:Object3D ):Void{

	}

	public function areCustomAttributesDirty(material:Material):Bool{

	}

	public function clearCustomAttributes(material:Material):Void{

	}

	public function removeObject(object:Object3D, scene:Scene):Void{

	}

	public function removeInstances(objlist:Array<Object3D>, object:Object3D):Void{

	}

	public function removeInstancesDirect(objlist:Array<Object3D>, object:Object3D):Void{

	}

	private function initMaterial(material:Material, lights:Array<Light>, fog:Fog, object:Object3D):Void{

	}

	public function setMaterialShaders(material:Material, shaders:Dynamic):Void{

	}

	public function setProgram(camera:Camera, lights:Array<Light>, fog:Fog, material:Material, object:Object3D):Dynamic{

	}

	public function refreshUniformsCommon(uniforms:Dynamic,  material:Material):Void{

	}

	public function refreshUniformsLine(uniforms:Dynamic,  material:Material):Void{

	}

	public function refreshUniformsDash(uniforms:Dynamic,  material:Material):Void{

	}

	public function refreshUniformsParticle(uniforms:Dynamic,  material:Material):Void{

	}	

	public function refreshUniformsFog(uniforms:Dynamic, fog:Fog):Void{

	}

	public function refreshUniformsPhong(uniforms:Dynamic,  material:Material):Void{

	}

	public function refreshUniformsLambert(uniforms:Dynamic,  material:Material):Void{

	}

	public function refreshUniformsLights(uniforms:Dynamic,  lights:Array<Light>):Void{

	}

	public function refreshUniformsShadow(uniforms:Dynamic,  lights:Array<Light>):Void{

	}

	public function loadUniformsMatrices(uniforms:Dynamic, object:Object3D):Void{

	}

	public function getTextureUnit():Void{

	}

	public function loadUniformsGeneric(program:Dynamic, uniforms:Dynamic){

	}

	public function setupMatrices(object:Object3D, camera:Camera):Void{

	}

	public function setColorGamma(array:Array<Color>, offset:Int, color:Color, intensitySq:Float):Void{

	}

	public function setColorLinear(array:Array<Color>, offset:Int, color:Color, intensity:Float):Void{

	}

	public function setupLights(program:Dynamic, lights:Array<Light>):Void{

	}

	private function setFaceCulling(cullFace:Int, frontFaceDirection:Int) : Void{

	}

	private function setMaterialFaces(material:Material) : Void{

	}

	private function setDepthTest(depthTest:Int) : Void{

	}

	private function setDepthWrite(depthWrite:Int) : Void{

	}

	private function setLineWidth(width:Float):Void{

	}

	private function setPolygonOffset(polygonoffset:Bool, factor:Float, units:Float ):Void{

	}

	private function setBlending(blending:Int, ?blendEquation:Int, ?blendSrc:Int, ?blendDst:Int) : Void{

	}

	public function generateDefines(defines:Dynamic):Dynamic{

	}

	public function buildProgram(shaderID:String, fragmentShader:String, vertexShader:String, uniforms:Dynamic, attributes:Dynamic, defines:Dynamic, parameters:Dynamic, index0AttributeName:Dynamic):Dynamic{

	}

	public function cacheUniformLocations(program:Dynamic, identifiers:Dynamic):Void{

	}

	public function cacheAttributeLocations(program:Dynamic, identifiers:Dynamic):Void{

	}

	public function addLineNumbers(string:String):Dynamic{

	}

	public function getShader(type:String, string:String):String{

	}

	public function isPowerOfTwo(value:Int):Bool{

	}

	public function setTextureParameters(textureType:String, texture:Texture, isImagePowerOfTwo:Bool):Void{

	}

	private function setTexture(texture:Texture, slot:Int):Void{

	}

	public function clampToMaxSize(image:BitmapData, maxSize:Int):BitmapData{

	}

	public function setCubeTexture(texture:Texture, slot:Int):Void{

	}

	public function setCubeTextureDynamic(texture:Texture, slot:Int):Void{

	}

	public function setupFrameBuffer(framebuffer:Array<Dynamic>, renderTarget:Dynamic, textureTarget:String):Void{

	}

	public function setupRenderBuffer(renderbuffer:Array<Dynamic>, renderTarget:Dynamic ):Void{

	}

	private function setRenderTarget(renderTarget:Dynamic):Void{

	}

	public function updateRenderTargetMipmap(renderTarget:Dynamic):Void{

	}

	public function filterFallback(f:Float):Float{

	}

	private function paramThreeToGL(p:Dynamic):Dynamic{

	}

	private function allocateBones(object:Object3D):Object3D{

	}

	private function allocateLights(lights:Array<Light>):Dynamic{

	}

	private function allocateShadows(lights:Array<Light>):Int{

	}

	private function initGL():Void{

	}

	private function setDefaultGLState():Void{
		
	}
}