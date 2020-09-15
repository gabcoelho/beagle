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

package br.com.zup.beagle.sample.builder

import br.com.zup.beagle.widget.action.Alert
import br.com.zup.beagle.core.CornerRadius
import br.com.zup.beagle.core.Style
import br.com.zup.beagle.ext.applyFlex
import br.com.zup.beagle.ext.applyStyle
import br.com.zup.beagle.ext.unitReal
import br.com.zup.beagle.sample.constants.*
import br.com.zup.beagle.widget.Widget
import br.com.zup.beagle.widget.action.Navigate
import br.com.zup.beagle.widget.action.Route
import br.com.zup.beagle.widget.core.EdgeValue
import br.com.zup.beagle.widget.core.TextAlignment
import br.com.zup.beagle.widget.layout.Container
import br.com.zup.beagle.widget.layout.NavigationBar
import br.com.zup.beagle.widget.layout.NavigationBarItem
import br.com.zup.beagle.widget.layout.Screen
import br.com.zup.beagle.widget.layout.ScreenBuilder
import br.com.zup.beagle.widget.ui.Button
import br.com.zup.beagle.widget.ui.ImagePath.Local
import br.com.zup.beagle.widget.ui.Text

object ButtonScreenBuilder : ScreenBuilder {
    override fun build() = Screen(
        child = Container(
            children = listOf(
                Text(
                    styleId = SCREEN_TEXT_STYLE,
                    text = "alert action",
                    alignment = TextAlignment.CENTER
                ).applyStyle(
                    Style(margin = EdgeValue(
                        top = 32.unitReal()
                    ))
                ),
                Text(
                    styleId = SCREEN_TEXT_STYLE,
                    text = "o tocar em um dos botões abaixo, a ação customizada de AlertAction será executada, abrindo a bottomsheet do iti malia.",
                    alignment = TextAlignment.CENTER
                ).applyStyle(
                    Style(margin = EdgeValue(
                        top = 16.unitReal()
                    ))
                ),
                Button(
                    styleId = "Background.Gradient.Glitch",
                    text = "/textAppearances",
                    onPress = listOf(
                        Navigate.PushView(
                            route = Route.Remote(
                                url = "/textAppearances",
                                shouldPrefetch = false
                            )
                        )
                    )
                ).applyStyle(
                    Style(
                        margin = EdgeValue(top = 16.unitReal())
                    )
                )

            )
        ).applyStyle(
            style = Style(backgroundColor = "#a88332")
        )
    )

    private fun buttonWithAppearanceAndStyle(text: String, styleId: String? = null) = createButton(
        text = text,
        styleId = styleId,
        style = Style(
            backgroundColor = CYAN_BLUE,
            cornerRadius = CornerRadius(radius = 16.0),
            margin = EdgeValue(
                left = 25.unitReal(),
                right = 25.unitReal(),
                top = 15.unitReal()
            )
        )
    )

    private fun createButton(
        text: String,
        styleId: String? = null,
        style: Style? = null
    ): Widget {
        val button = Button(
            text = text,
            styleId = styleId,
            onPress = listOf(Navigate.PushView(Route.Remote(SCREEN_ACTION_CLICK_ENDPOINT, true)))
        )

        if (style != null) {
            button.applyStyle(style)
        }

        return button
    }
}