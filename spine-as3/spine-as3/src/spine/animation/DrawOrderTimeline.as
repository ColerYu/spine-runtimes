/******************************************************************************
 * Spine Runtimes License Agreement
 * Last updated January 1, 2020. Replaces all prior versions.
 *
 * Copyright (c) 2013-2020, Esoteric Software LLC
 *
 * Integration of the Spine Runtimes into software or otherwise creating
 * derivative works of the Spine Runtimes is permitted under the terms and
 * conditions of Section 2 of the Spine Editor License Agreement:
 * http://esotericsoftware.com/spine-editor-license
 *
 * Otherwise, it is permitted to integrate the Spine Runtimes into software
 * or otherwise create derivative works of the Spine Runtimes (collectively,
 * "Products"), provided that each user of the Products must obtain their own
 * Spine Editor license and redistribution of the Products in any form must
 * include this license and copyright notice.
 *
 * THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
 * BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THE SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

package spine.animation {
	import spine.Event;
	import spine.Skeleton;
	import spine.Slot;

	public class DrawOrderTimeline implements Timeline {
		public var frames : Vector.<Number>; // time, ...
		public var drawOrders : Vector.<Vector.<int>>;

		public function DrawOrderTimeline(frameCount : int) {
			frames = new Vector.<Number>(frameCount, true);
			drawOrders = new Vector.<Vector.<int>>(frameCount, true);
		}

		public function get frameCount() : int {
			return frames.length;
		}

		public function getPropertyId() : int {
			return TimelineType.drawOrder.ordinal << 24;
		}

		/** Sets the time and value of the specified keyframe. */
		public function setFrame(frameIndex : int, time : Number, drawOrder : Vector.<int>) : void {
			frames[frameIndex] = time;
			drawOrders[frameIndex] = drawOrder;
		}

		public function apply(skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, blend : MixBlend, direction : MixDirection) : void {
			if (direction == MixDirection.Out) {
				if (blend == MixBlend.setup) {
					for (var ii : int = 0, n : int = skeleton.slots.length; ii < n; ii++)
						skeleton.drawOrder[ii] = skeleton.slots[ii];
				}
				return;
			}

			var drawOrder : Vector.<Slot> = skeleton.drawOrder;
			var slots : Vector.<Slot> = skeleton.slots;
			var slot : Slot;
			var i : int = 0;
			if (time < frames[0]) {
				if (blend == MixBlend.setup || blend == MixBlend.first) {
					for each (slot in slots)
						drawOrder[i++] = slot;
				}
				return;
			}

			var frameIndex : int;
			if (time >= frames[int(frames.length - 1)]) // Time is after last frame.
				frameIndex = frames.length - 1;
			else
				frameIndex = Animation.binarySearch1(frames, time) - 1;

			var drawOrderToSetupIndex : Vector.<int> = drawOrders[frameIndex];
			i = 0;
			if (!drawOrderToSetupIndex) {
				for each (slot in slots)
					drawOrder[i++] = slot;
			} else {
				for each (var setupIndex : int in drawOrderToSetupIndex)
					drawOrder[i++] = slots[setupIndex];
			}
		}
	}
}
