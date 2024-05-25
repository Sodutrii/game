using Godot;
using System;

public partial class Player_movement : CharacterBody3D
{
	private float _sensitivity = 0.001f;

	private float _speed;
	private float _walkSpeed = 5.0f;
	private float _sprintSpeed = 8.0f;
	private float _jumpVelocity = 4.8f;
	
	private float _bobFrequency = 2.4f;
	private float _bobAmplitude = 0.08f;
	private float _tBob = 0.0f;

	private float _baseFov = 75.0f;
	private float _fovChange = 1.5f;

	private float _gravity = (float)ProjectSettings.GetSetting("physics/3d/default_gravity");
	private Vector3 velocity = Godot.Vector3.Zero;

	private Camera3D _camera;
	private Node3D _head;
	
	public override void _Ready()
	{
		_head = GetNode<Node3D>("Head");
		_camera = _head.GetChild<Camera3D>(0);
		Input.MouseMode = Input.MouseModeEnum.Captured;
	}
	
	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseMotion eventMouseMotion)
		{
			_head.RotateY(-eventMouseMotion.Relative.X * _sensitivity);
			_camera.RotateX(-eventMouseMotion.Relative.Y * _sensitivity);
			_camera.Rotation = new Vector3(Mathf.Clamp(_camera.Rotation.X, Mathf.DegToRad(-40), Mathf.DegToRad(60)), 0, 0);
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		// Get the input direction and handle the movement/deceleration.
		Vector2 inputDir = Input.GetVector("left", "right", "up", "down");
		Vector3 direction = (_head.GlobalTransform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();//_head.Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y).Normalized();
		
		// Add the gravity.
		if (!IsOnFloor())
		{
			velocity.Y -= _gravity + (float)delta;
		}

		// Handle Jump.
		if (Input.IsActionJustPressed("jump") && IsOnFloor())
		{
			
			velocity.Y = _jumpVelocity;
		}

		// Handle Sprint.
		_speed = Input.IsActionPressed("sprint") ? _sprintSpeed : _walkSpeed;
		
		if (IsOnFloor())
		{
			if (direction != Vector3.Zero)
			{
				velocity.X = direction.X * _speed;
				velocity.Y = direction.Z * _speed;
			}
			else
			{
				velocity.X = Mathf.Lerp(velocity.X, direction.X * _speed, (float)delta * 10.0f);
				velocity.Z = Mathf.Lerp(velocity.Z, direction.Z * _speed, (float)delta * 10.0f);
			}
		}
		else
		{
			velocity.X = Mathf.Lerp(velocity.X, direction.X * _speed, (float)delta * 3.0f);
			velocity.Z = Mathf.Lerp(velocity.Z, direction.Z * _speed, (float)delta * 3.0f);
		}

		// Head bob
		//_tBob += (float)delta * velocity.Length() * (IsOnFloor() ? 1.0f : 0.0f);
		//_camera.Transform = new Transform3D(_camera.Transform.Basis, Headbob(_tBob));

		// FOV
		var velocityClamped = Mathf.Clamp(velocity.Length(), 0.5f, _sprintSpeed * 2);
		var targetFov = _baseFov + _fovChange * velocityClamped;
		_camera.Fov = Mathf.Lerp(_camera.Fov, targetFov, (float)delta * 8.0f);

		Velocity = velocity;
		MoveAndSlide();
	}
	
	private Vector3 Headbob(float time)
	{
		return new Vector3(
			Mathf.Cos(time * _bobFrequency / 2) * _bobAmplitude,
			Mathf.Sin(time * _bobFrequency) * _bobAmplitude,
			0);
	}
}

