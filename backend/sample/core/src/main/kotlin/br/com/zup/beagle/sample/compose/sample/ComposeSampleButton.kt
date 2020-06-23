/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package br.com.zup.beagle.sample.compose.sample

import br.com.zup.beagle.core.CornerRadius
import br.com.zup.beagle.core.ServerDrivenComponent
import br.com.zup.beagle.core.Style
import br.com.zup.beagle.ext.applyFlex
import br.com.zup.beagle.ext.applyStyle
import br.com.zup.beagle.ext.unitReal
import br.com.zup.beagle.sample.constants.BUTTON_STYLE
import br.com.zup.beagle.sample.constants.BUTTON_STYLE_APPEARANCE
import br.com.zup.beagle.sample.constants.CYAN_BLUE
import br.com.zup.beagle.sample.constants.SCREEN_ACTION_CLICK_ENDPOINT
import br.com.zup.beagle.widget.Widget
import br.com.zup.beagle.widget.action.Navigate
import br.com.zup.beagle.widget.action.Route
import br.com.zup.beagle.widget.core.EdgeValue
import br.com.zup.beagle.widget.core.Flex
import br.com.zup.beagle.widget.layout.ComposeComponent
import br.com.zup.beagle.widget.layout.Container
import br.com.zup.beagle.widget.ui.Button


object ComposeSampleButton: ComposeComponent {
    override fun build(): ServerDrivenComponent {
        return Container(
            children = listOf(
                createButton(
                    text = "Button",
                    flex = Flex(
                        margin = EdgeValue(
                            top = 15.unitReal()
                        )
                    )
                ),

                createButton(
                    text = "Button with style",
                    styleId = BUTTON_STYLE,
                    flex = Flex(
                        margin = EdgeValue(
                            top = 15.unitReal()
                        )
                    )
                ),

                buttonWithAppearanceAndStyle(text = "Button with Appearance"),
                buttonWithAppearanceAndStyle(
                    text = "Button with Appearance and style",
                    styleId = BUTTON_STYLE_APPEARANCE
                )
            )
        )
    }

    private fun buttonWithAppearanceAndStyle(text: String, styleId: String? = null) = createButton(
        text = text,
        styleId = styleId,
        flex = Flex(
            margin = EdgeValue(
                left = 25.unitReal(),
                right = 25.unitReal(),
                top = 15.unitReal()
            )
        )
    ).applyStyle(
        Style(
            backgroundColor = CYAN_BLUE,
            cornerRadius = CornerRadius(radius = 16.0)
        )
    )

    private fun createButton(
        text: String,
        styleId: String? = null,
        flex: Flex? = null
    ): Widget {
        val button = Button(
            text = text,
            styleId = styleId,
            onPress = listOf(Navigate.PushView(Route.Remote(SCREEN_ACTION_CLICK_ENDPOINT, true)))
        )

        if (flex != null) {
            button.applyFlex(flex)
        }

        return button
    }
}